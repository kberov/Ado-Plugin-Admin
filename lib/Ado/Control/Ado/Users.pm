package Ado::Control::Ado::Users;
use Mojo::Base 'Ado::Control::Ado';

my $U = 'Ado::Model::Users';
$U->SQL('SELECT_DESCENDING' => $U->SQL('SELECT')
      . ' ORDER BY id DESC '
      . $U->SQL_LIMIT('?', '?'));

#available users on this system
sub list {
    my $c = shift;
    $c->require_formats('json', 'html') || return;
    my $args = Params::Check::check(
        {   limit => {
                allow => sub { $_[0] =~ /^\d+$/ ? 1 : ($_[0] = 20); }
            },
            offset => {
                allow => sub { $_[0] =~ /^\d+$/ ? 1 : defined($_[0] = 0); }
            },
        },
        {   limit  => $c->req->param('limit')  // '',
            offset => $c->req->param('offset') // '',
        }
    );

    #$c->debug('$args ' => $c->dumper($args));
    $c->res->headers->content_range(
        "users $$args{offset}-${\($$args{limit} + $$args{offset})}/*");

    state $SQL = $U->SQL('SELECT_DESCENDING');
    my $list_for_json = $c->list_for_json([$$args{limit}, $$args{offset}],
        [$U->query($SQL, $$args{limit}, $$args{offset})]);
    $c->title($c->l('Users'));

    #content negotiation
    return $c->respond_to(
        json => $list_for_json,
        html => {list_for_json => $list_for_json}
    );
}


sub add {
    return shift->render(text => 'not implemented...');
}

sub show {
    return shift->render(text => 'not implemented...');
}

sub update {
    return shift->render(text => 'not implemented...');
}

sub disable {
    return shift->render(text => 'not implemented...');
}

1;


=pod

=encoding utf8

=head1 NAME

Ado::Control::Ado::Users - The controller to manage users. 

=head1 SYNOPSIS

  #in your browser go to
  http://your-host/ado-users/list
  #or
  http://your-host/ado-users
  #and
  http://your-host/ado-users/edit/$id
  #and
  http://your-host/ado-users/add

=head1 DESCRIPTION

Ado::Control::Ado::Users is the controller class for managing users in the
back-office application.

=head1 ATTRIBUTES

L<Ado::Control::Ado::Users> inherits all the attributes from 
<Ado::Control::Ado>.

=head1 METHODS/ACTIONS

L<Ado::Control::Ado::Users> inherits all methods from
L<Ado::Control::Ado> and implements the following new ones.
        
=head2 list

Displays the users this system has.
Uses the request parameters C<limit> and C<offset> to display a range of items
starting at C<offset> and ending at C<offset>+C<limit>.
This method serves the resource C</ado-users/list.json>.
If other format is requested returns status 415 with C<Content-location> header
pointing to the proper URI.
See L<http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html#sec10.4.16> and
L<http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.14>.

=head2 add

Adds a user to the table users. Not implemented yet.

=head2 show

Displays a user. Not implemented yet.

=head2 update

Updates a user. Not implemented yet.

=head2 disable

Disables a user. Not implemented yet.

=head1 SPONSORS

The original author

=head1 SEE ALSO

L<Ado::Plugin::Admin>, L<Ado::Control::Ado::Default>,
L<Ado::Control>, L<Mojolicious::Controller>,
L<Mojolicious::Guides::Growing/Model_View_Controller>,
L<Mojolicious::Guides::Growing/Controller_class>


=head1 AUTHOR

Красимир Беров (Krasimir Berov)

=head1 COPYRIGHT AND LICENSE

Copyright 2013-2015 Красимир Беров (Krasimir Berov).

This program is free software, you can redistribute it and/or
modify it under the terms of the 
GNU Lesser General Public License v3 (LGPL-3.0).
You may copy, distribute and modify the software provided that 
modifications are open source. However, software that includes 
the license may release under a different license.

See http://opensource.org/licenses/lgpl-3.0.html for more information.

=cut

