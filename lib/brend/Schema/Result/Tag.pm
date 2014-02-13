use utf8;
package brend::Schema::Result::Tag;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

brend::Schema::Result::Tag

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

=head1 TABLE: C<tags>

=cut

__PACKAGE__->table("tags");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 tag

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "tag",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-08-20 07:08:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Dv0kb5T1PKUrWtoC5VM7jQ

__PACKAGE__->has_many(
	'post_tags',
	'brend::Schema::Result::PostTag',
	{ "foreign.tag_id" => "self.id" },
	{ cascade_copy => 1, cascade_delete => 1 },
);

__PACKAGE__->many_to_many(posts => 'post_tags', 'posts');

__PACKAGE__->has_many(
	'blog_tags',
	'brend::Schema::Result::BlogTag',
	{ "foreign.tag_id" => "self.id" },
	{ cascade_copy => 1, cascade_delete => 1 },
);

__PACKAGE__->many_to_many(blogs => 'blog_tags', 'shop_blogs');

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
