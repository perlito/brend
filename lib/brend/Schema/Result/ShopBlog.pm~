use utf8;
package brend::Schema::Result::ShopBlog;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

brend::Schema::Result::ShopBlog

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

=head1 TABLE: C<shop_blogs>

=cut

__PACKAGE__->table("shop_blogs");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 shop

  data_type: 'integer'
  is_nullable: 1

=head2 header

  data_type: 'text'
  is_nullable: 1

=head2 post

  data_type: 'text'
  is_nullable: 1

=head2 thumbnail

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 date

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "shop",
  { data_type => "integer", is_nullable => 1 },
  "header",
  { data_type => "text", is_nullable => 1 },
  "post",
  { data_type => "text", is_nullable => 1 },
  "thumbnail",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "date",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-08-21 07:08:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Me3z7Tr0WwUPgXyeVxE/vQ

__PACKAGE__->has_many(
	'blog_tags',
	'brend::Schema::Result::BlogTag',
	{ "foreign.blog_id" => "self.id" },
	{ cascade_copy => 1, cascade_delete => 1 },
);

__PACKAGE__->many_to_many(tags => 'blog_tags', 'tags');


__PACKAGE__->belongs_to(
	'shop' => 'brend::Schema::Result::Shop'
);
# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
