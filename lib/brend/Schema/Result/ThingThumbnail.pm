use utf8;
package brend::Schema::Result::ThingThumbnail;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

brend::Schema::Result::ThingThumbnail

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

=head1 TABLE: C<thing_thumbnails>

=cut

__PACKAGE__->table("thing_thumbnails");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 small

  data_type: 'text'
  is_nullable: 1

=head2 medium

  data_type: 'text'
  is_nullable: 1

=head2 big

  data_type: 'text'
  is_nullable: 1

=head2 thing

  data_type: 'integer'
  is_nullable: 1

=head2 num

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "small",
  { data_type => "text", is_nullable => 1 },
  "medium",
  { data_type => "text", is_nullable => 1 },
  "big",
  { data_type => "text", is_nullable => 1 },
  "thing",
  { data_type => "integer", is_nullable => 1 },
  "num",
  { data_type => "integer", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07027 @ 2012-08-31 09:10:58
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Psv3JpxBVOUb4zlJGlHpVw
__PACKAGE__->belongs_to(
	'thing' => 'brend::Schema::Result::Thing',
);

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
