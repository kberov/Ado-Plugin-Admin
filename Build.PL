use 5.014;
use strict;
use warnings FATAL => 'all';
use Ado::BuildPlugin;

my $builder = Ado::BuildPlugin->new(
    module_name        => 'Ado::Plugin::Admin',
    license            => 'lgpl_3_0',
    dist_version_from  => 'lib/Ado/Plugin/Admin.pm',
    create_license     => 1,
    create_readme      => 1,
    dist_author        => q{Your Name <you@cpan.org>},
    release_status     => 'unstable',
    build_requires     => {'Test::More' => 0,},
    requires           => {Ado => '0.76',},
    add_to_cleanup     => ['Ado-Plugin-Admin-*', '*.bak'],
);

$builder->create_build_script();
