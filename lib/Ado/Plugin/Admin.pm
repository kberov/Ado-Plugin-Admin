package Ado::Plugin::Admin;
use Mojo::Base 'Ado::Plugin';
use Ado::UI::Menu;
use Mojo::Util qw(encode monkey_patch);
our $VERSION = '0.05';

sub register {
    my ($self, $app, $config) = shift->initialise(@_);
    $self->_init_admin_menu();

    return $self;
}

sub _init_admin_menu {
    my $self = shift;
    my $menu =
      Ado::UI::Menu->new(header => 1, icon => 'ado', title => 'Plugins');
    $menu->items(
        {title => 'Dashboard', url   => '/ado', icon => 'dashboard'},
        {icon  => 'content',   title => 'Content'},
        {icon  => 'setting',   title => 'System'}
      )->first(sub { $_[0]->title eq 'System' })->items(
        {icon => 'settings', title => 'Settings', url => '/ado-settings'},
        {icon => 'users',    title => 'Users',    url => '/ado-users'},
      );
    $menu->items->first(sub { $_[0]->title eq 'Content' })->items(
        {icon => 'browser', title => 'Pages', url => '/ado-pages'},
        {icon => 'content', title => 'Blog',  url => '/ado-blog'},
    );
    monkey_patch ref($self->app), admin_menu => sub {$menu};
    return;
}
1;

__END__

=encoding utf8

=head1 NAME

Ado::Plugin::Admin - system (site) administration user interface

=head1 SYNOPSIS

  #Add this plugin to configuration file
  # /home/you/whereinstalled/Ado/etc/ado.$mode.config
  plugins => {
    # other plugins here...
    'admin',
    # other plugins depending on Ado::Plugin::Admin here...
  }

  #run/restart ado
  $ cd /hereis/ado
  morbo ./bin/ado

  #go to http://localhost:3000/ado
  #enjoy

=head1 DESCRIPTION

L<Ado::Plugin::Admin> provides:

=over

=item * REST API for default home page for the administration area
of your site or web-application;

=item * API for other plugins that want to provide user interface for administering various parts of the application;

=item * Default UI consisting of a left panel and a default dashboard.
The dashboard consists of descriptions of the installed plugins that
provide description for the dashboard

B<Note:> This software is not funtional yet!

=back

=head1 METHODS

L<Ado::Plugin::Admin> inherits all methods from
L<Ado::Plugin> and implements the following new ones.

=head2 register

  $plugin->register(Ado->new);

Initializes and registers plugin in L<Ado> application.

=head1 SEE ALSO

L<Ado::UI::Menu>, L<Ado::Control::Ado::Default>, L<Ado::Control::Ado::Users>,
L<Ado::Plugin>, L<Mojolicious::Guides::Growing>,
L<Ado::Manual>, L<Mojolicious>,  L<http://mojolicio.us>.

=head1 AUTHOR

Krasimir Berov

=head1 COPYRIGHT AND LICENSE

Copyright 2015 Krasimir Berov.

This program is free software, you can redistribute it and/or
modify it under the terms of the 
GNU Lesser General Public License v3 (LGPL-3.0).
You may copy, distribute and modify the software provided that 
modifications are open source. However, software that includes 
the license may release under a different license.

See http://opensource.org/licenses/lgpl-3.0.html for more information.

=cut
