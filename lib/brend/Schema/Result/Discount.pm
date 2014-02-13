use utf8;
package brend::Schema::Result::Discount;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

brend::Schema::Result::Discount

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

=head1 TABLE: C<discount>

=cut

__PACKAGE__->table("discount");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 shop

  data_type: 'integer'
  is_nullable: 1

=head2 discount

  data_type: 'text'
  is_nullable: 1

=head2 active_till

  data_type: 'text'
  is_nullable: 1

=head2 collection

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "shop",
  { data_type => "integer", is_nullable => 1 },
  "discount",
  { data_type => "text", is_nullable => 1 },
  "active_till",
  { data_type => "text", is_nullable => 1 },
  "collection",
  { data_type => "integer", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-08-21 16:36:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:QogW5RAtVr54KjaLEwdF6w

__PACKAGE__->belongs_to(
	'collection' => 'brend::Schema::Result::Collection'
);

__PACKAGE__->belongs_to(
	'shop' => 'brend::Schema::Result::Shop',
);
# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
