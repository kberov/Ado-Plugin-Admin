use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('Ado');

my $class = 'Ado::Plugin::Admin';
isa_ok($class, 'Ado::Plugin');
can_ok($class, 'register');

# Add meaningfull tests here...

done_testing();
