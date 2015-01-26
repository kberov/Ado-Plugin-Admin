package Ado::UI::MenuItem;
use Mojo::Base -base;
use Mojo::Collection qw(c);

has icon => 'caret right';
has 'title';
has 'url';

sub items {
  my $self = shift;
  return $self->{items} = c(map { Ado::UI::MenuItem->new($_) } @_) if @_;
  return $self->{items} = c() unless $self->{items};
  return $self->{items};
}

sub add_item {
  my $self = shift;
  push @{$self->{items}}, Ado::UI::MenuItem->new(@_);
  return $self;
}


1;

=pod

=encoding utf8

=head1 NAME

Ado::UI::MenuItem - A user interface component 

=head1 SYNOPSIS

=head1 DESCRIPTION

L<Ado::UI::AdmninMenu> is a UI component for managing and rendering the
main menu in the administration interface of an L<Ado>-based application.

=head1 METHODS

L<Ado::UI::MenuItem> inherits all methods from
L<Mojo::Base> and implements the following new ones.

=head2 items

Creates a  L<Mojo::Collection> of L<Ado::UI::MenuItem>s or returns an empty one.

  $menu->sections->last->items(
    {icon => 'block layout', title =>'Templates', url=>'/ado-templates'},
    {icon => 'users', title =>'Users', url=>'/ado-users'},
  );
  my $items = $menu->sections->first(sub{shift->title =~/^Sett/})->items;

=head2 add_item

Adds an item at the end of the L</items> collection and returns C<$self>.

  # 'users'
  $menu->add_item(icon => 'users', title =>'Users',url=>'/ado-users')
    ->items->last->icon;

=head1 SEE ALSO

L<Ado::UI::AdmninMenu>, L<Mojo::Collection>


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
