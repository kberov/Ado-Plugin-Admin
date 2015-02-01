package Ado::UI::Menu;
use Mojo::Base -base;
use Mojo::Collection qw(c);

has header => 0;
has icon   => 'caret right';
has 'title';
has 'url';

sub items {
    my $self = shift;
    return $self->{items} = c(map { Ado::UI::Menu->new($_) } @_) if @_;
    return $self->{items} = c() unless $self->{items};
    return $self->{items};
}

sub add_item {
    my $self = shift;
    push @{$self->{items}}, Ado::UI::Menu->new(@_);
    return $self;
}


1;

=pod

=encoding utf8

=head1 NAME

Ado::UI::Menu - A user interface component

=head1 SYNOPSIS

  my $menu = Ado::UI::Menu->new;
  $menu->items(
    {icon => 'dashboard', title => 'Dashboard'},
    {icon => 'content',   title => 'Content'},
    {icon => 'settings',  title => 'Settings'}
  );

  $menu->items->last->add_item(
    icon => 'users', title => 'Users', url => '/ado-users');


=head1 DESCRIPTION

L<Ado::UI::Menu> is a UI component created for populating
the main menu in the administration interface of an
L<Ado>-based application.
It can be used also in the site area by L<Ado::Plugin::Site>.
Every menu-item is an instance of Ado::UI::Menu too.

=head1 ATTRIBUTES

L<Ado::UI::Menu> inherits all attributes from
L<Mojo::Base> and implements the following new ones.

=head2 header

  $item->header(1)
  $item->header; #this item is a header item

Boolean. Is this menu-item a header or not.

=head2 icon

  $item->icon('dashboard');
  $item->icon; # dashboard

String. Used to set CSS class for the icon. 
See L<http://semantic-ui.com/elements/icon.html>,
L<http://fortawesome.github.io/Font-Awesome/icons/>.

=head2 title

  $item->title('Dashboard');
  $item->title; # Dashboard

String. Used to display the text of the menu item.

=head2 url

  $item->url('/ado-users');
  $item->url;# '/ado-users'

=head1 METHODS

L<Ado::UI::Menu> inherits all methods from
L<Mojo::Base> and implements the following new ones.

=head2 items

Creates a  L<Mojo::Collection> of L<Ado::UI::Menu>s or returns an empty one.

  $menu->items(
    {icon => 'block layout', title =>'Templates', url=>'/ado-templates'},
    {icon => 'users', title =>'Users', url=>'/ado-users'},
  );
  my $items_level2 = $menu->items->first(sub{shift->title =~/^Sett/})->items;

=head2 add_item

Adds an item at the end of the L</items> collection and returns C<$self>.

  # 'users'
  $menu->add_item(icon => 'users', title =>'Users',url=>'/ado-users')
    ->items->last->icon;

=head1 SEE ALSO

L<Ado::Plugin::Admin>, L<Mojo::Collection>

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
