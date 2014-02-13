use utf8;
package brend::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

brend::Schema::Result::User

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

=head1 TABLE: C<users>

=cut

__PACKAGE__->table("users");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 username

  data_type: 'varchar'
  is_nullable: 1
  size: 25

=head2 firstname

  data_type: 'text'
  is_nullable: 1

=head2 lastname

  data_type: 'text'
  is_nullable: 1

=head2 userpic

  data_type: 'text'
  is_nullable: 1

=head2 social

  data_type: 'text'
  is_nullable: 1

=head2 mail

  data_type: 'varchar'
  is_nullable: 1
  size: 25

=head2 password

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "username",
  { data_type => "varchar", is_nullable => 1, size => 25 },
  "firstname",
  { data_type => "text", is_nullable => 1 },
  "lastname",
  { data_type => "text", is_nullable => 1 },
  "userpic",
  { data_type => "text", is_nullable => 1 },
  "social",
  { data_type => "text", is_nullable => 1 },
  "mail",
  { data_type => "varchar", is_nullable => 1, size => 25 },
  "password",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07027 @ 2012-08-30 15:30:16
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:QIcPeuu0GQnjBn5jNtLcbA

__PACKAGE__->add_columns(
    'password' => {
        passphrase       => 'rfc2307',
        passphrase_class => 'SaltedDigest',
        passphrase_args  => {
            algorithm   => 'SHA-1',
            salt_random => 20.
        },
        passphrase_check_method => 'check_password',
    },
);

__PACKAGE__->has_many(
	'user_roles',
	'brend::Schema::Result::UserRole',
	{ "foreign.user_id" => "self.id"},
	{ cascade_delete=>1, cascade_copy=>1 },
);

__PACKAGE__->many_to_many(roles => 'user_roles', 'roles');

__PACKAGE__->might_have(
	shop =>
	'brend::Schema::Result::Shop',
	{ 'foreign.manager' => 'self.id' },
);
# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
