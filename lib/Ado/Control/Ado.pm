package Ado::Control::Ado;
use Mojo::Base 'Ado::Control';
use Mojo::Cache;
has _cache => sub { Mojo::Cache->new };

# Meta data for models and CRUD used by all back-end controllers.
# Clients should request this before manipulating records.
sub meta {
    my $c     = shift;
    my $class = ref($c);
    state $cache = $c->_cache;
    $c->debug("metadata about $class...");

    #$c->require_formats('json') || return;
    if (my $json = $cache->get($class . "_meta")) {
        return $c->render(json => $json);
    }
    $c->debug("collecting metadata about $class...");
    my ($model_class) = $class =~ /(\w+)$/;
    my $M = 'Ado::Model::' . $model_class;
    state $routes = $c->app->routes;
    my ($m, $c_routes, $action);

    #add
    $m = Mojolicious::Routes::Match->new(root => $routes);
    $action = 'add';
    if ($c->can($action)
        && $m->find(
            $c => {
                method => 'POST',
                path   => '/ado-' . lc($model_class) . '/' . $action
            }
        )
      )
    {
        $c_routes->{$action} = {
            path_for => $m->path_for,
            pattern  => $m->endpoint->pattern->unparsed,
            method   => 'POST',
            over     => $m->endpoint->over
        };
    }

    #show
    $m = Mojolicious::Routes::Match->new(root => $routes);
    $action = 'show';
    if ($c->can($action)
        && $m->find(
            $c => {
                method => 'GET',
                path   => '/ado-' . lc($model_class) . "/$action/123"
            }
        )
      )
    {
        $c_routes->{$action} = {
            path_for => $m->path_for,
            pattern  => $m->endpoint->pattern->unparsed,
            method   => 'GET',
            over     => $m->endpoint->over
        };
    }

    #update
    $m = Mojolicious::Routes::Match->new(root => $routes);
    $action = 'update';
    if ($c->can($action)
        && $m->find(
            $c => {
                method => 'PUT',
                path   => '/ado-' . lc($model_class) . "/$action/123"
            }
        )
      )
    {
        $c_routes->{action} = {
            path_for => $m->path_for,
            pattern  => $m->endpoint->pattern->unparsed,
            method   => 'PUT',
            over     => $m->endpoint->over
        };
    }

    #disable
    $m = Mojolicious::Routes::Match->new(root => $routes);
    $action = 'disable';
    if ($c->can($action)
        && $m->find(
            $c => {
                method => 'DELETE',
                path   => '/ado-' . lc($model_class) . "/$action/123"
            }
        )
      )
    {
        $c_routes->{disable} = {
            path_for => $m->path_for,
            pattern  => $m->endpoint->pattern->unparsed,
            method   => 'DELETE',
            over     => $m->endpoint->over
        };
    }

    my $json = {
        TABLE   => $M->TABLE,
        COLUMNS => $M->COLUMNS,
        ALIASES => $M->ALIASES,
        CHECKS  => $M->CHECKS,
        actions => $c_routes,
    };
    $cache->set($class . "_meta" => $json);
    return $c->render(json => $json);
}

1;

=pod

=encoding utf8

=head1 NAME

Ado::Control::Ado - Base controller class for L<Ado> back-office applications. 

=head1 SYNOPSIS

package Ado::Control::Ado::MyAdoApp;
use Mojo::Base 'Ado::Control::Ado';
#your code here
1;

=head1 DESCRIPTION

Ado::Control::Ado is the base controller class for all back-office controllers.

=head1 ATTRIBUTES

Ado::Control::Ado inherits all the attributes from
<Ado::Control> and does not define new attributes to share among
all back-office controllers.




=head1 METHODS/ACTIONS

Ado::Control::Ado inherits all methods from L<Ado::Control::Ado> and
implements the following new ones.

=head2 meta

  http://localhost:3000/ado-users/meta.json

Provides meta information for the resource behind this controller.
Can be used by client application authors to retrieve information about what
actions can be applied on a resource.




=head1 SPONSORS

The original author

=head1 SEE ALSO

L<Ado::Control>, L<Mojolicious::Controller>, L<Mojolicious::Guides::Growing/Model_View_Controller>,
L<Mojolicious::Guides::Growing/Controller_class>


=head1 AUTHOR

Красимир Беров (Krasimir Berov)

=head1 COPYRIGHT AND LICENSE

Copyright 2013-2014 Красимир Беров (Krasimir Berov).

This program is free software, you can redistribute it and/or
modify it under the terms of the 
GNU Lesser General Public License v3 (LGPL-3.0).
You may copy, distribute and modify the software provided that 
modifications are open source. However, software that includes 
the license may release under a different license.

See http://opensource.org/licenses/lgpl-3.0.html for more information.

=cut

