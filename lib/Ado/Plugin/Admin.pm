package Ado::Plugin::Admin;
use Mojo::Base 'Ado::Plugin';
our $VERSION = '0.01';

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

Ado::Plugin::Admin - an Ado Plugin that does foooooo.

=head1 SYNOPSIS

  # /home/berov/opt/public_dev/Ado/etc/ado.config
  plugins => {
    # other plugins here...
    'Admin',
    # other plugins here...
  }

=head1 DESCRIPTION

L<Ado::Plugin::Admin> is an L<Ado> plugin.

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

Your Name

=head1 COPYRIGHT AND LICENSE

Copyright 2015 Your Name.

This program is free software, you can redistribute it and/or
modify it under the terms of the 
GNU Lesser General Public License v3 (LGPL-3.0).
You may copy, distribute and modify the software provided that 
modifications are open source. However, software that includes 
the license may release under a different license.

See http://opensource.org/licenses/lgpl-3.0.html for more information.

=cut
