#admin_menu.t
use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

my $t     = Test::Mojo->new('Ado');
my $class = 'Ado::UI::Menu';
use_ok($class);
isa_ok($class, 'Mojo::Base');
can_ok($class, 'items');

# Add meaningfull tests here...

my $menu = $class->new();
isa_ok($menu,        $class);
isa_ok($menu->items, 'Mojo::Collection');
isa_ok($menu->items, 'Mojo::Collection');

my $items = $menu->items(
  {icon => 'dashboard', title => 'Dashboard'},
  {icon => 'content',   title => 'Content'},
  {icon => 'settings',  title => 'Settings'}
);
isa_ok($menu->add_item(icon => 'bla', title => 'Something'), $class);
ok(my $last_item = $items->last, 'defined $last_item');
is($last_item->icon,   'bla',       'right last section icon');
is($last_item->title,  'Something', 'right title');
is($last_item->header, 0,           'not a header item');
is($last_item->url,    undef,       'right url');

isa_ok($last_item->items, 'Mojo::Collection');

my $items1 = $last_item->items(
  {icon => 'block layout', title => 'Templates', url => '/ado-templates'});
isa_ok($last_item->add_item(icon => 'users', title => 'Users', url => '/ado-users'),
  $class);


done_testing();
