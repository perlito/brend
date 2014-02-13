use utf8;
package brend::Schema::Result::UserRole;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

brend::Schema::Result::UserRole

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::TimeStamp>

=item * L<DBIx::Class::PassphraseColumn>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "PassphraseColumn");

=head1 TABLE: C<user_roles>

=cut

__PACKAGE__->table("user_roles");

=head1 ACCESSORS

=head2 user_id

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 role_id

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "user_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "role_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</user_id>

=item * L</role_id>

=back

=cut

__PACKAGE__->set_primary_key("user_id", "role_id");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-08-20 07:08:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:7IMW6tMID8OxsaTwCdoKZw

__PACKAGE__->belongs_to(
	'users',
	'brend::Schema::Result::User',
	{ 'id' => 'user_id' },
	{ join_type => "LEFT", on_delete => "CASCADE", on_update => "CASCADE" },
);

__PACKAGE__->belongs_to(
	'roles',
	'brend::Schema::Result::Role',
	{ 'id' => 'role_id' },
	{ join_type => "LEFT", on_delete => "CASCADE", on_update => "CASCADE" },
);

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
