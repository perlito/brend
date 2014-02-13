package brend::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=head1 NAME

brend::Controller::Root - Root Controller for brend

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut
#our @rubrics;
# Define wrapper to this controller actions 
sub begin :Private {
	my ( $self, $c ) = @_;
	
	my @adds = $c->model('DB::Add')->all;
	my %adds;
	foreach my $add (@adds) {
		$adds{$add->alias} = $add->adds;	
	}
	# Set wrapper
	$c->stash( 
		wrapper => 'site_wrapper.tt2',
		rubrics => [ $c->model('DB::Rubric')->all ],
		types  => [ $c->model('DB::ShopType')->all ],
		now	  => time,
		adds 	  => \%adds,
	 ); 
}

# Home page controller
sub index :Path :Args(0) :Sitemap {
   my ( $self, $c ) = @_;

	my @posts = reverse $c->model('DB::Post')->all();
	my @collections = reverse $c->model('DB::Collection')->all();
	my @new_collections = splice(@collections, 0, 7);
	my @top_posts = splice(@posts, 0, 5);
	my @new_posts = splice(@posts, 0, 15);
	my @blog_posts = reverse $c->model('DB::ShopBlog')->all();
	my @top_blog_posts = splice(@blog_posts, 0, 7); 
	my @discounts = reverse $c->model('DB::Discount')->all;
	my @top_discounts = splice(@discounts, 0, 7);

   $c->stash( 
   	template			 => 'index.tt2',
		top_posts		 => \@top_posts,
		new_collections => \@new_collections,
		blog_posts		 => \@top_blog_posts,
		discounts 		 => \@top_discounts,
		new_posts		 => \@new_posts,
   );
}
#######################################################################################################################
# 																Shop Part																				 #
#######################################################################################################################
sub shop :Path Args(1) {
	my ($self, $c , $alias) = @_;
		my $shop = $c->model('DB::Shop')->find({ alias => $alias }, ); 
		if ( $shop ) {
		$c->stash(
			template => 'shop.tt2',
			shop 		=> $shop,		
		);
		}

		else {
			$c->stash(template => 'not_found.tt2');
		}

}

sub base :Chained('/') :PathPart('shop') :CaptureArgs(1) {
	my ($self, $c, $id ) = @_;

	$c->stash->{shop} = $c->model('DB::Shop')->find({ id => $id });

}

sub obj_shop :Chained('base') :PathPart('obj_shop') :CaptureArgs(1) {
	my ($self, $c, $id ) = @_;
	
	$c->stash->{shop} = $c->model('DB::Shop')->find({id =>$id });
}

sub show_collections :Chained('base') :PathPart('show_collections') :Args(0) {
	my ($self, $c ) = @_;
	
	$c->stash(template => 'shop/collections.tt2',title => "ÕÕ¡Õ¾Õ¡ÖÕ¡Õ®Õ¸ÖÕ¶Õ¥Ö" );
}

sub shop_blog :Chained('base') :PathPart('shop_blog') :Args(1) {
	my ($self, $c, $page ) = @_;
	
	my $result =  $c->model('DB::ShopBlog')->search({shop => $c->stash->{shop}->id },  {order_by => { -desc => 'id' }}) ;
	
	$result = $result->page($page);
	$result->pager;
	$c->stash(
				template => 'shop/blog.tt2',
				result 	=> $result,
				pager 	=>	$result->pager,
				);
}

sub shop_info :Chained('base') :PathPart('shop_info') :Args(0) {
	my ($self, $c ) = @_;
	
	$c->stash(template => 'shop/info.tt2');
}

sub shop_discounts :Chained('base') :PathPart('shop_discounts') :Args(0) {
	my ($self, $c) = @_;
	
	$c->stash(template => 'shop/discounts.tt2');
}

sub thing :Chained('/') :PathPart('thing') :Args(1) {
	my ($self, $c, $id ) = @_;
	
	my $thing = $c->model('DB::Thing')->find({ id => $id });
	
	$c->stash(
				template => 'shop/single_thing.tt2',
				title		=> $thing->shop->shop,
				shop 		=> $thing->shop,
				collection => $thing->collection,
				current_thing 	=> $thing 
		); 
}

sub shop_post :Chained('/') :PathPart('shop_post') :Args(1) {
	my ( $self, $c, $id ) = @_;
	
	my $post = $c->model('DB::ShopBlog')->find({ id => $id });
	
	$c->stash(
				template => 'shop/post.tt2',
				title 	=> 'post.header',
				post 		=> $post,
				shop 		=> $post->shop
				);
	
}
#######################################################################################################################
# 																Blog Part																				 #
#######################################################################################################################


# Display single post
sub post :Local :Args(1) :Sitemap {
	my ( $self, $c, $id ) = @_;
	
	my $post = $c->model('DB::Post')->find({ id => $id });
	my $rubric = $c->model('DB::Rubric')->find({ id => $post->rubric->id });
	my @posts = reverse $c->model('DB::Post')->all();
	my @top_posts = splice(@posts, 0, 10);
	my @tags = $post->tags;
	my @rel_posts;
	foreach my $tag (@tags) {
		push @rel_posts, $tag->posts;	
	}
	
	$c->stash(
				template => 'single.tt2',
				title 	=> $post->header,
				post 		=> $post,	
				rubric 	=> $rubric,
				posts		=> \@top_posts,
				rel_posts => \@rel_posts,
				);
}

# Display Rubrics
sub rubric :Local :Args(2) {
	my ($self, $c, $id, $page ) = @_;
	
	my $posts = $c->model('DB::Post')->search({ rubric => $id }, {order_by => { -desc => 'id' }});
	my $rubric = $c->model('DB::Rubric')->find({ id => $id });
	$posts = $posts->page($page);
	$posts->pager;
	my @posts = reverse $c->model('DB::Post')->all();
	my @top_posts = splice(@posts, 0, 10);
	$c->stash(
				template => 'rubric.tt2',
				title		=> $rubric->rubric,
				posts	   => $posts,
				pager 	=> $posts->pager,
				rubric 	=> $rubric,
				top_posts    => \@top_posts,
				);
		
}



#######################################################################################################################
# 																Additional																				 #
#######################################################################################################################

sub tag :Local :Args(1) {
	my ($self, $c, $id ) = @_;
	
	my $tag = $c->model('DB::Tag')->find({ id => $id });
	
	$c->stash(
				template => 'tag.tt2',
				title 	=> $tag->tag,
				tag		=> $tag, 
				);
}

sub search :Local :Args(0) {
	my ($self, $c) = @_;
	
	my $string = $c->request->params->{search};
	


	my %results;
	my %b_results;
	$results{post_headers}  = [ $c->model('DB::Post')->search({ header => { -like => "%$string%"} }) ];
	$results{posts} = [ $c->model('DB::Post')->search({ post => { -like => "%$string%"}}) ]; 
	$b_results{shop_headers} =  [ $c->model('DB::ShopBlog')->search({ header => { -like => "%$string%"}}) ];
	$b_results{shop_posts} = [ $c->model('DB::ShopBlog')->search({ post => { -like => "%$string%"}}) ];
	$c->stash(
				template => 'search.tt2',
				title    => "$string ÕÖÕ¸Õ¶Õ´Õ¡Õ¶ Õ¡ÖÕ¤ÕµÕ¸ÖÕ¶ÖÕ¶Õ¥ÖÕ¨",
				results 	=> \%results,
				b_results => \%b_results,
				string  => $string,
				);
}

#######################################################################################################################
# 																Experimental																			 #
#######################################################################################################################

sub ajax :Local :Args(0) {
	my ($self, $c) = @_;

	my $file = $c->request->upload('file');
	$file->copy_to('root/images/ajax/'); 

	$c->stash(template => 'ajax/ajax.tt2', no_wrapper => 1, file => $file);
}
=head2 default

Standard 404 error page

=cut

sub sitemap : Path('/sitemap') {
    my ( $self, $c ) = @_;
 
    $c->res->body( $c->sitemap_as_xml );
}

sub default :Path {
    my ( $self, $c ) = @_;
    $c->stash(template => 'not_found.tt2');
    
    $c->response->status(404);
}


=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

Tigran,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
