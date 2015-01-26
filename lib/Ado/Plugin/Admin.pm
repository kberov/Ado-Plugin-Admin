package Ado::Plugin::Admin;
use Mojo::Base qw(Ado::Plugin);
our $VERSION = '0.02';

sub register {
  my ($self, $app, $config) = shift->initialise(@_);

  # Do your magic here.
  # You may want to add some helpers
  # or some new complex routes definitions,
  # or register this plugin as a template renderer.
  # Look in Mojolicious and Ado sources for examples and inspiration.
  return $self;
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

=head1 DESCRIPTION

L<Ado::Plugin::Admin> provides:

=over

=item * REST API for default home page for the administration area
of your site or web-application;

=item * API for other plugins that want to provide user interface for administering various parts of the application;

=item * Default UI consisting of a left panel and a default dashboard.
The dashborad consists of descriptions of the installed plugins that
provide description for the dashboard

B<Note:> This software is not funtional yet!

=back

=head1 METHODS

L<Ado::Plugin::Admin> inherits all methods from
L<Ado::Plugin> and implements the following new ones.

=head2 register

  $plugin->register(Ado->new);

Register plugin in L<Ado> application.

=head1 SEE ALSO

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
