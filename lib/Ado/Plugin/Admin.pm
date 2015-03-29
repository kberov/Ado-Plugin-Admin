package Ado::Plugin::Admin;
use Mojo::Base 'Ado::Plugin';
use Ado::UI::Menu;
use Mojo::Util qw(monkey_patch);
our $VERSION = '0.12';

sub register {
    my ($self, $app, $config) = shift->initialise(@_);
    $self->_init_admin_menu();

    #User specific Admin menu
    $app->helper(admin_menu => \&_render_admin_menu);

    #switch layouts depending on XMLHttpRequest
    $app->hook(
        around_action => sub {
            my ($next, $c, $action, $last_in_stack) = @_;
            if ($c->user->login_name ne 'guest') {

                #Add link to admin area for logged-in users
                List::Util::first(
                    sub { $_->{href} eq '/ado' },
                    @{$c->stash->{adobar_links}}
                  )
                  || push @{$c->stash->{adobar_links}},
                  {icon => 'dashboard', href => '/ado', text => 'Dashboard'};
            }

            if (($c->stash->{controller} // '') =~ m|^ado|) {
                if   ($c->req->is_xhr) { $c->layout('admin_xhr') }
                else                   { $c->layout('admin') }
            }
            return $next->();
        }
    );
    $app->hook(
        after_login => sub {
            push @{$_[0]->session->{adobar_links}},
              {icon => 'dashboard', href => '/ado', text => 'Dashboard'};
        }
    );

    #may be used later
    #$app->plugin("AssetPack");
    #$app->asset('admin.css' => ('/plugins/admin/admin.css'));
    #$app->asset('admin.js'  => ('/plugins/admin/admin.js'));
    return $self;
}

sub _init_admin_menu {
    my $self = shift;
    my $menu =
      Ado::UI::Menu->new(header => 1, icon => 'ado', title => 'Plugins');
    $menu->items(
        {title => 'Dashboard', url => '/ado', header => 1, icon => 'dashboard'},
        {title => 'Content', icon => 'content', header => 1,},
        {title => 'System',  icon => 'setting', header => 1,}
      )->first(sub { $_[0]->title eq 'System' })->items(
        {title => 'Settings', icon => 'settings', url => '/ado-settings'},
        {title => 'Users',    icon => 'users',    url => '/ado-users'},
      );
    $menu->items->first(sub { $_[0]->title eq 'Content' })->items(
        {title => 'Pages', icon => 'browser', url => '/ado-pages'},
        {title => 'Blog',  icon => 'content', url => '/ado-blog'},
    );
    monkey_patch ref($self->app), admin_menu => sub {$menu};
    return;
}


# Rendered once and cached in the user session.
sub _render_admin_menu {
    my $c = shift;

    # return prepared HTML
    return $c->session('admin_menu') if $c->session('admin_menu');

    my $menu = $c->render_to_string(
        template => '/ado/partials/admin_menu',
        item     => $c->app->admin_menu
    );
    $c->session('admin_menu' => $menu);    # session cache
    return $menu;
}
1;

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

=head1 HELPERS

L<Ado::Plugin::Admin> provides the following helpers

=head2 admin_menu

TODO: Renders the main menu in the administration screen in html or json for the current user.

  <%= admin_menu %>

=head1 CONTINUOUS INTEGRATION

We would like to know that our software is always in good health.
We count on friendly developers and organizations to install and test it continuously.

L<CPAN Testers Reports for Ado::PLugin::Admin|http://www.cpantesters.org/distro/A/Ado-Plugin-Admin.html>

L<Travis-CI|https://travis-ci.org/kberov/Ado-Plugin-Admin> 


=begin html

 <a href="https://travis-ci.org/kberov/Ado-Plugin-Admin"><img 
  src="https://travis-ci.org/kberov/Ado-Plugin-Admin.svg?branch=master"
    ></a><br /><br />

end html

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
