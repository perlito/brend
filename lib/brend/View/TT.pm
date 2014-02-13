package brend::View::TT;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt2',
    render_die => 1,
    INCLUDE_PATH => [brend->path_to('root', 'src')],
    TIMER => 0,
    WRAPPER => 'wrapper.tt2',
);

=head1 NAME

brend::View::TT - TT View for brend

=head1 DESCRIPTION

TT View for brend.

=head1 SEE ALSO

L<brend>

=head1 AUTHOR

Tigran,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
