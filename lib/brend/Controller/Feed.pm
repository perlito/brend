package brend::Controller::Feed;
use Moose;
use strict;
use warnings;
use XML::Feed;
use DateTime;
use utf8;
use Encode;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }


sub atom : Local {
	my ($self, $c) = @_;
	$c->stash->{type} = 'Atom';
}
sub rss : Local {
	my ($self, $c) = @_;
	$c->stash->{type} = 'RSS';
}

sub end :Private {
	my ($self, $c) = @_;
	my $feed = XML::Feed->new($c->stash->{type});
	my $datetime = DateTime->now();	
	
	
	$feed->title("brend.am");
	$feed->link($c->uri_for('/'));
	$feed->description("brend.am news");
	$feed->generator("brend.am / brend.am");
	#$feed->author("brend.am");
	#$feed->language('hy');
	$feed->modified($datetime);
	my @posts = reverse $c->model('DB::Post')->all;
	splice @posts, 5;
	
	foreach my $post (@posts) {
		my $entry = XML::Feed::Entry->new($c->stash->{type});
		
		my $header = decode("utf8", $post->header);
		$entry->title($header);
		
		
		if ($post->lead) {
			my $lead = decode("utf8", $post->lead);
			$entry->summary($lead);
		} else {

			$entry->summary($header);
		}
		$entry->issued($post->modify);

		$entry->link($c->uri_for($c->controller('Root')->action_for('post'), $post->id));
		
		$feed->add_entry($entry);
	}
	
	$c->res->content_type('application/xhtml+xml; charset=UTF-8');
	
	$c->res->body($feed->as_xml);
}


=head1 AUTHOR

Tigran,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
