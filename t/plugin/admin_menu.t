#admin_menu.t
use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

my $t     = Test::Mojo->new('Ado');
my $class = 'Ado::UI::AdminMenu';
use_ok($class);
isa_ok($class, 'Mojo::Base');
can_ok($class, 'sections');

# Add meaningfull tests here...

my $menu = $class->new();
isa_ok($menu,           $class);
isa_ok($menu->sections, 'Mojo::Collection');
isa_ok($menu->sections, 'Mojo::Collection');

my $sections = $menu->sections(
  {icon => 'dashboard', title => 'Dashboard'},
  {icon => 'content',   title => 'Content'},
  {icon => 'settings',  title => 'Settings'}
);
isa_ok($menu->add_section(icon => 'bla', title => 'Something'), $class);
is($sections->last->icon, 'bla', 'right last section icon');

$class = 'Ado::UI::MenuItem';
isa_ok($sections->last->items, 'Mojo::Collection');
isa_ok($sections->last->items, 'Mojo::Collection');

my $items = $sections->last->items(
  {icon => 'block layout', title => 'Templates', url => '/ado-templates'});
isa_ok(
  $sections->last->add_item(icon => 'users', title => 'Users', url => '/ado-users'),
  $class);


done_testing();
