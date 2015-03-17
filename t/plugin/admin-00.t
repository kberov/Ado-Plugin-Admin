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
use Ado::Model::Users;


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
subtest 'ado-users' => sub {

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
      ->json_is('/data/0/login_name' => 'null', 'right login_name')
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
my $i      = 6;
my $output = '';
my $rd     = Time::Piece->new();
$rd->add_years(-10);

#Clean database from previous test runs
$dbix->query('DELETE from user_group WHERE user_id>=?', $i);
$dbix->query('DELETE from users WHERE id>=?',           $i);
$dbix->query('DELETE from groups WHERE id>=?',          $i);
$dbix->query('VACUUM');


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
    $dbix->query('INSERT INTO `groups` VALUES(?,?,?,1,1,0)', $i, $un, $un);
    $dbix->query(
        q{INSERT INTO `users` VALUES(
          ?1,?1,?2,?5,?3,?4,?2 || '@localhost', ?11,1,1,?7,?6,?8,?9,?10)},
        $i, $un, $fn, $ln, $p, $rd->epoch,
        ($i =~ /6$/    ? int(rand(time))       : $rd->epoch),
        ($i =~ /7$/    ? 1                     : 0),
        ($i % 2        ? $rd->epoch            : 0),
        (($i % 8 == 0) ? ($rd->epoch + 120365) : 0),
        $de
    );
    $dbix->query('INSERT INTO `user_group` VALUES(?1,?1)', $i);

    $i++;
}    #end foreach

subtest 'ado-users-gui' => sub {

#say dumper($names);
    is(@{Ado::Model::Users->select_range(100, 50)},
        100, 'good, we have enough users to play with');

};
done_testing();
