package Ado::UI::AdminMenu;
use Mojo::Base -base;
use Mojo::Collection qw(c);
use Ado::UI::MenuItem;

sub sections {
  my $self = shift;
  return $self->{sections} = c(map { Ado::UI::MenuItem->new($_) } @_) if @_;
  return $self->{sections} = c() unless $self->{sections};
  return $self->{sections};
}

sub add_section {
  my $self = shift;
  push @{$self->{sections}}, Ado::UI::MenuItem->new(@_);
  return $self;
}


1;

=pod

=encoding utf8

=head1 NAME

Ado::UI::AdmninMenu - A user interface component 

=head1 SYNOPSIS

=head1 DESCRIPTION

L<Ado::UI::AdmninMenu> is a UI component for managing and rendering the
main menu in the administration interface of an L<Ado>-based application.

=head1 METHODS

L<Ado::UI::AdmninMenu> inherits all methods from
L<Mojo::Base> and implements the following new ones.

=head2 sections

Creates a  L<Mojo::Collection> of L<Ado::UI::MenuItem>s or returns an empty one.

  $menu->sections(
    {icon => 'dashboard', title =>'Dashboard'},
    {icon => 'content', title =>'Content'},
    {icon => 'settings', title =>'Settings'},
  );
  $menu->sections->first(sub{shift->{title} =~/^Con/})
    ->add_item({icon => 'comments', title =>'Comments' url =>'/ado/comments'});

=head2 add_section

Adds a section at the end of the L</sections> collection and returns C<$self>.

  # 'settings'
  $menu->add_section(icon => 'settings', title =>'Settings')
    ->sections->last->icon;

=head1 SEE ALSO

L<Ado::UI::MenuItem>, L<Mojo::Collection>

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
