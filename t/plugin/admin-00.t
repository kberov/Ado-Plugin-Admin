use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('Ado');

my $class = 'Ado::Plugin::Admin';
use_ok($class);
isa_ok($class, 'Ado::Plugin');
can_ok($class, 'register');

# Add meaningfull tests here...

done_testing();
