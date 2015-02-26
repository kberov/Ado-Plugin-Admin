#!perl
use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use File::Spec::Functions qw(splitdir catdir catfile);
use File::Basename;
use Cwd qw(abs_path);


#use our own ado.conf
$ENV{MOJO_HOME} = abs_path dirname(__FILE__);
$ENV{MOJO_CONFIG} = catfile($ENV{MOJO_HOME}, 'ado.conf');

# Make sure the database file is writable!
chmod(oct('0600'), catfile($ENV{MOJO_HOME}, 'ado_admin.sqlite'))
  or plan skip_all => 'ado_admin.sqlite cannot be made writable!';

my $class = 'Ado::Plugin::Admin';
my $t     = Test::Mojo->new('Ado');
my $app   = $t->app;
my $home  = $app->home;
my $dbh   = $app->dbix->dbh;
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

#restapi
    $t->get_ok('/ado-users', {Accept => 'text/plain'})
      ->status_is(415, '415 - Unsupported Media Type for any other format');
    $t->get_ok('/ado-users.json')->status_is(200);
    $t->get_ok('/ado-users')->status_is(204)
      ->content_type_is(undef, 'no content type');
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

};    #end end_to_end

done_testing();
