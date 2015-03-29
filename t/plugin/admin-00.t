#!perl
use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use File::Spec::Functions qw(splitdir catdir catfile);
use File::Basename;
use Cwd qw(abs_path);
use Mojo::Util qw(slurp dumper decode encode sha1_sum squish);
use Time::Piece;
use Time::Seconds;
use List::Util qw(shuffle);


#use our own ado.conf
$ENV{MOJO_HOME} = abs_path dirname(__FILE__);
$ENV{MOJO_CONFIG} = catfile($ENV{MOJO_HOME}, 'ado.conf');

# Make sure the database file is writable!
chmod(oct('0600'), catfile($ENV{MOJO_HOME}, 'ado_admin.sqlite'))
  or plan skip_all => 'ado_admin.sqlite cannot be made writable!';

my $class = 'Ado::Plugin::Admin';
my $t     = Test::Mojo->new('Ado');
my $app   = $t->app;
my $dbix  = $app->dbix;
my $home  = $app->home;
my $admin = $app->plugin('admin');

isa_ok($admin, $class);

subtest run_plugin_with_own_ado_config_and_database => sub {
    isa_ok($app->admin_menu => 'Ado::UI::Menu');

#first we need to login!!!
    my $login_url =
      $t->get_ok('/ado')->status_is(302)
      ->header_like('Location' => qr|/login$|)
      ->tx->res->headers->header('Location');

    $t->get_ok('/login/ado');
    my $form           = $t->tx->res->dom->at('#login_form');
    my $new_csrf_token = $form->at('[name="csrf_token"]')->{value};

    $t->post_ok(
        $login_url => {},
        form       => {
            _method        => 'login/ado',
            login_name     => 'test1',
            login_password => '',
            csrf_token     => $new_csrf_token,
            digest         => Mojo::Util::sha1_hex(
                $new_csrf_token . Mojo::Util::sha1_hex('test1' . 'test1')
            ),
          }

          #redirect back to the $c->session('over_route')
    )->status_is(302)->header_is('Location' => '/ado');

# default ado page
    $t->get_ok('/ado')->status_is(200)
      ->content_like(qr/Controller: ado-default; Action: index/);


};    #end run_plugin_with_own_ado_config_and_database
my $U = 'Ado::Model::Users';

#Clean database from previous test runs
$dbix->begin;
my $uid = $dbix->query(
    q'
  SELECT id from users WHERE id>(SELECT id from users WHERE login_name=?)
  ', 'test2'
)->hash;
$uid //= {id => 5};
$dbix->query('DELETE from user_group WHERE user_id>=?', $uid->{id});
$dbix->query('DELETE from users WHERE id>=?',           $uid->{id});
$dbix->query('DELETE from groups WHERE id>=?',          $uid->{id});
$dbix->commit;
$dbix->query('VACUUM');

subtest 'ado-users' => sub {

    #die $U->SQL('SELECT_DESCENDING');
#my $udata = [$U->query($U->SQL('SELECT_DESCENDING'), 20,0)];

#restapi
    $t->get_ok('/ado-users', {Accept => 'text/plain'})
      ->status_is(415, '415 - Unsupported Media Type for any other format');
    $t->get_ok('/ado-users.json')->status_is(200)
      ->content_type_is('application/json', 'json content type');
    $t->get_ok('/ado-users')->status_is(200)
      ->content_type_is('text/html;charset=UTF-8', 'html content type');
    $t->get_ok('/ado-users', {Accept => 'application/json'})->status_is(200);
    $t->get_ok('/ado-users.json', form => {limit => 2, offset => 2})
      ->status_is(200)
      ->json_is('/data/0/login_name' => 'guest', 'right login_name')
      ->json_has('/links', 'has links');
    $t->get_ok('/ado-users.json', form => {limit => 'bla', offset => 'noo'})
      ->status_is(200)
      ->json_is('/data/0/login_name' => 'test2', 'right login_name')
      ->json_like('/links/0/href', qr/limit=20\&offset=0/,
        'has default limit and offset');

#TODO: implement underlying functionality
    $t->get_ok('/ado-users/show/3', form => {login_name => 'foo'})
      ->status_is(200)->content_like(qr/not implemented/);
    $t->post_ok('/ado-users/add', form => {login_name => 'foo'})
      ->status_is(200)->content_like(qr/not implemented/);
    $t->put_ok('/ado-users/update/3', form => {login_name => 'foo'})
      ->status_is(200)->content_like(qr/not implemented/);
    $t->delete_ok('/ado-users/disable/3', form => {login_name => 'foo'})
      ->status_is(200)->content_like(qr/not implemented/);
};    #end ado-users

#Admin gui
# Let us add some more users
#The list of these users is publicly available at
#http://bg.wikipedia.org/w/index.php?title=Списък_на_служители_и_сътрудници_на_Държавна_сигурност
my $names = [
    shuffle split /\n/,
    decode('UTF-8', slurp($home->rel_file('random_names.txt')))
];
my $i      = 5;
my $output = '';
my $rd     = Time::Piece->new();
$rd->add_years(-10);


foreach my $n (@$names) {
    $n = squish $n;
    my ($fn, $ln, $de) = split(/\s/, $n, 3);
    my $un =
        chr(100 + int(rand(15)))
      . chr(101 + int(rand(10)))
      . chr(102 + int(rand(11)))
      . chr(103 + int(rand(12)))
      . $i;
    $ln //= $fn //= ucfirst($un);
    my $p = sha1_sum($un . $i);
    $rd += ONE_DAY + ONE_WEEK + int(rand(ONE_DAY)) if ($i % 2 == 0);
    $rd -= ONE_DAY + int(rand(ONE_WEEK)) + ONE_WEEK + ONE_DAY if ($i % 3 == 0);
    $rd += int(rand(ONE_DAY)) * int($i / 2) if ($i % 5 == 0);
    $rd -= ONE_DAY + ONE_WEEK + ONE_WEEK + ONE_DAY * $i if ($rd > time);
    $dbix->query(
        'INSERT INTO `groups` 
      (name,description,created_by,changed_by,disabled)
      VALUES(?,?,1,1,0)', $un, 'froup for ' . $un
    );
    $dbix->query(
        q{INSERT INTO `users` 
          (group_id,login_name,login_password,first_name,last_name,email,
          description,created_by,changed_by,tstamp,reg_date,disabled,start_date,stop_date)
          VALUES(
            (SELECT id FROM groups WHERE name=?1),?2,?5,?3,?4,?2 || '@localhost', ?11,1,1,?7,?6,?8,?9,?10)},
        $un, $un, $fn, $ln, $p, $rd->epoch,
        ($i =~ /6$/    ? int(rand(time))       : $rd->epoch),
        ($i =~ /7$/    ? 1                     : 0),
        ($i % 2        ? $rd->epoch            : 0),
        (($i % 8 == 0) ? ($rd->epoch + 120365) : 0),
        $de
    );
    $dbix->query(
        'INSERT INTO user_group VALUES(
        (SELECT id FROM users WHERE login_name=?),
        (SELECT id FROM groups WHERE name=?))', $un, $un
    );

    $i++;
}    #end foreach

subtest 'ado-users-gui-list' => sub {
    my $udata = [$U->query($U->SQL('SELECT_DESCENDING'), 10, 5)];

    is(@$udata, 10, 'good, we have enough users to play with');

    #users' grid
    $t->get_ok('/ado-users?limit=10&offset=5')->status_is(200)
      ->text_like('style', qr|plugins/admin/admin.css|, 'admin.css is referred')
      ->element_exists('#tab_title',          'We have list title')
      ->element_exists('#tab_body',           'We have list body')
      ->element_exists('.ui.one.column.grid', 'main grid for listing')
      ->element_exists('#users_list_controls.right.aligned.two.column.row',
        'header section for controls')
      ->element_exists('.ui.pagination.menu .left.arrow.icon',  '<prev|')
      ->element_exists('.ui.pagination.menu .right.arrow.icon', '|next>')
      ->element_exists('.ui.pagination.menu .ui.dropdown.item',
        'limit & offset')
      ->element_exists('#users_list_controls .column .add.user.icon',
        'add user button')
      ->element_exists('#users_list_header.five.column.header.black.row',
        'header section for column names')->element_exists(
        '#users_list #u' . $udata->[0]->data->{id} . '.row',
        "first row (${\ $udata->[0]->data->{id}}) id is present"
        )->element_exists(
        '#users_list #u' . $udata->[-1]->data->{id} . '.row',
        "last row (${\ $udata->[-1]->data->{id}}) id is present"
        )->element_exists('script[src="plugins/admin/admin.js"]',
        'admin.js is referred')

      #admin sidebar
      ->element_exists('#admin_menu', 'admin_menu is rendered')
      ->element_exists('#admin_menu a[href="/ado-users"]',
        'Users item is rendered');

    #grid requested by jQuery
    $udata = [$U->query($U->SQL('SELECT_DESCENDING'), 100, 5)];

    is(@$udata, 100, 'good, we have enough users to play with');

    $t->get_ok('/ado-users?limit=100&offset=5' =>
          {'X-Requested-With' => 'XMLHttpRequest'})->status_is(200)
      ->element_exists_not('#admin_menu', 'admin_menu is not rendered')
      ->content_like(
        qr|^\<\!--\sstart\sadousers\s--\>|x,
        'only right side with grid via Ajax'
      )->content_like(
        qr|\<\!--\send\sadousers\s--\>\n$|x,
        'only right side with grid via Ajax'
      )->element_exists('#tab_title', 'We have list title')
      ->element_exists('#tab_body',           'We have list body')
      ->element_exists('.ui.one.column.grid', 'main grid for listing')
      ->element_exists('#users_list_controls.right.aligned.two.column.row',
        'header section for controls')
      ->element_exists('.ui.pagination.menu .left.arrow.icon',  '<prev|')
      ->element_exists('.ui.pagination.menu .right.arrow.icon', '|next>')
      ->element_exists('.ui.pagination.menu .ui.dropdown.item',
        'limit & offset')
      ->element_exists('#users_list_controls .column .add.user.icon',
        'add user button')
      ->element_exists('#users_list_header.five.column.header.black.row',
        'header section for column names')->element_exists(
        '#users_list #u' . $udata->[0]->data->{id} . '.row',
        "first row (${\ $udata->[0]->data->{id}}) id is present"
        )->element_exists(
        '#users_list #u' . $udata->[-1]->data->{id} . '.row',
        "last row (${\ $udata->[-1]->data->{id}}) id is present"
        )

      #say dumper($udata->[-1]->data);

};
done_testing();
