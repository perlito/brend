package brend::Controller::Manager;
use Moose;
use namespace::autoclean;
use Image::Magick::Thumbnail::Fixed;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

brend::Controller::Manager - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut


# Authorization logic
sub auto :Private {
	my ($self, $c) = @_;
	
	if(!$c->user_exists ) {
		$c->response->redirect($c->uri_for('/login/manager'));	
	}
	 elsif ( !$c->check_user_roles('manager') ) {
		$c->response->redirect($c->uri_for('/login/manager'));	
	} else {
	
		my $now = time;
		my $shop = $c->model('DB::Shop')->find({ id => $c->user->shop->id });
		my $active_till = $shop->active_till;
		$c->stash(now => $now, active_till => $active_till);
	}
	return 1;
}


sub begin :Private {
	my ($self, $c) = @_;

	
		$c->stash(
		wrapper => 'manager/manager_wrapper.tt2',
		now => time, 
		);
	
}


sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
	 
	 $c->stash( template => 'manager/index.tt2' );
   
}

sub base :Chained('/') :PathPart('manager') :CaptureArgs(0) {
	my ( $self, $c ) = @_;

	$c->log->debug("*** Inside manager's base method ***");
}

######################
#	Collections CRUD	#
######################

sub show_collections :Chained('base') :PathPart('show_collections') :Args(0) {
	my ( $self, $c ) = @_;
	
	my $shop = $c->user->shop->id;
	my @collection = reverse $c->model('DB::Collection')->search({ shop => $shop });
	my $result = $c->model('DB::Collection')->search({ shop => $shop });
	$result = $result->page(1);
	$c->stash->{result} = $result;
	$c->stash->{pager} = $result->pager;
	$c->stash(
				template 	=> 'manager/show_collections.tt2',
				title 		=> 'show_collections',
				collection 	=> \@collection,
				uri 			=> 'add_collection_do',				
				);
				
}



sub add_collection_do :Chained('base') :PathPart('add_collection_do') :Args(0) {
	my ( $self, $c ) = @_;
	
	# Obtain Collection name
	my $collection = $c->request->params->{collection};
	
	# Define current shop
	my $shop = $c->user->shop->id;
	
	# Delete old collection
	my @collections = $c->model('DB::Collection')->search({ shop => $shop })->all;
	
	my $size = @collections;
	if ($size > 9) {
		my @col_id;
		$col_id[0] = $collections[0]->id;
		
		$c->forward('del_col', \@col_id);
		$c->log->debug("*** Collection with id $col_id[0] deleted ***");	
	}
	my $created = $c->model('DB::Collection')->create({
		collection => $collection,
		shop 		  => $shop,	
	});
	$c->response->redirect($c->uri_for($self->action_for('show_collections')));
}

sub obj_col :Chained('base') :PathPart('obj_collection') :CaptureArgs(1) {
	my ( $self, $c, $id ) = @_;
	
	$c->stash(obj_col => $c->model('DB::Collection')->find({ id => $id }));
	
	$c->stash(error => "Object with $id not found") unless ($c->stash->{obj_col});
		
	$c->log->debug("*** Object with id $id captured ***");
}



sub edit_collection :Chained('obj_col') :PathPart('edit_collection') :Args(0) {
	my ( $self, $c ) = @_;
	
	$c->stash(
		template => 'manager/edit_collection.tt2',
		uri 		=> 'edit_collection_do',
		button 	=> 'Փոփոխել',
	);
}

sub edit_collection_do :Chained('base') :PathPart('edit_collection_do') :Args(0) {
	my ($self, $c) = @_;
	
	my $collection = $c->request->params->{collection};
	my $id 			= $c->request->params->{col_id};
	
	my $editing = $c->model('DB::Collection')->find({ id => $id });
	$editing->collection($collection);
	$editing->update;
	
	$c->response->redirect($c->uri_for($self->action_for('show_collections'))); 
}

sub delete_collection :Chained('obj_col') :PathPart('delete_collection') :Args(0) {
	my ( $self, $c ) = @_;
	
	my @col_id;
	$col_id[0] = $c->stash->{obj_col}->id;
	
	$c->forward('del_col', \@col_id);	

	$c->response->redirect($c->uri_for($self->action_for('show_collections')));
}

sub del_col :Private {
	my ($self, $c, @col_id ) = @_;
	
	my @things = $c->model('DB::Thing')->search({ collection => $col_id[0] })->all;
	foreach my $thing(@things) {
		my @id;
		$id[0] = $thing->id;
		
		$c->forward( 'del_thing', \@id );	
	}
	my $collection = $c->model('DB::Collection')->find({ id => $col_id[0]});
	$collection->delete;
}
######################
#		Things CRUD		#
######################

sub show_things :Chained('obj_col') :PathPart('show_things') :Args(1) {
	my ($self, $c, $page ) = @_;
	
	my $collection = $c->stash->{obj_col}->id;
	my $things 		= $c->model('DB::Thing')->search({ collection => $collection },  {order_by => { -desc => 'id' }});
	
	$things = $things->page($page);
	$things->pager;
	
	$c->stash(
				template => 'manager/show_things.tt2',
				things	=> $things,
				pager 	=> $things->pager,
				col		=> $collection,
				title		=> 'things',
				);
	
}

sub add_thing :Chained('obj_col') :PathPart('add_thing') :Args(0) {
	my ( $self, $c ) = @_;

	$c->stash(
					template => 'manager/edit_thing.tt2',
					uri		=> "add_thing_do",
					button	=> 'Ավելացնել',
					types		=> [ $c->model('DB::ThingType')->all()],	
					ref 		=> $c->request->referer,		
				);
}

sub add_thing_do :Chained('base') :PathPart('add_thing_do') :Args(0) {
	my ( $self, $c ) = @_;
	
	$c->log->debug("*** Inside add_thing_do method ***");
	
	# Define parameters of thing and create it
	
	my $price 	 = $c->request->params->{price};
	my $discount = $c->request->params->{discount};
	my $type		 = $c->request->params->{type};
	my $info 	 = $c->request->params->{thing_info};
	my $col_id	 = $c->request->params->{collection_id};
	
	my $shop 	 = $c->user->shop->id;
	
	my $new_thing = $c->model('DB::Thing')->create({
		shop 	 	=> $shop,
		type	 	=> $type,
		info	 	=> $info,
		price	 	=> $price,
		discount => $discount,
		collection => $col_id,	
	});	
	
	# Define thing pictures and create apropriate thumbnails
	##################################
	my @pic;
	 $pic[0] = $c->request->upload('pic0');
	 $pic[1] = $c->request->upload('pic1');
	 $pic[2] = $c->request->upload('pic2');

	my $t = new Image::Magick::Thumbnail::Fixed;
	
	my @links;
	foreach (my $i = 0; $i < 3; $i++) {
		if( $pic[$i] ) {
			$pic[$i]->copy_to('root/static/images');
				
			# Get filename of uploaded file, and create corresponding image link
			my $filename = $pic[$i]->tempname;
			$filename =~ s{.+/}{};
			 
			# Create thumbnails 
		
			my $input = "root/static/images/" . $filename;
			my $output_small = "root/static/images/thumbnails/small/" . $filename;
			my $output_medium = "root/static/images/thumbnails/medium/" . $filename;
			my $output_big = "root/static/images/thumbnails/big/" . $filename;
			
			# Create small thumbnail
			$t->thumbnail(
							input => $input,
							output => $output_small,
							width => 60,
							height => 80,
							gravity => 'center',					
							);
			
			# Create medium thumbnail
			$t->thumbnail(
							input => $input,
							output => $output_medium,
							width => 300,
							height => 400,
							gravity => 'center',
							quality => '100'
							);
			
			# Create big thumbnail			
			$t->thumbnail(
							input => $input,
							output => $output_big,
							width => 900,
							height => 1200,
							gravity => 'center',
							quality => '100'
			);
			
			$c->model('DB::ThingThumbnail')->create({
				small	 => $c->uri_for('../static/images/thumbnails/small/') . $filename,
				medium => $c->uri_for('../static/images/thumbnails/medium/') . $filename,
				big 	 => $c->uri_for('../static/images/thumbnails/big/') . $filename,
				thing  => $new_thing->id,
				num 	 => $i,		
			});	
			
			my $file = "root/static/images/" . $filename;
			unlink $file;		
		} else {
				$c->log->debug("*** Empty row with $new_thing created ***");
				$c->model('DB::ThingThumbnail')->create({
					thing  => $new_thing->id,
					num 	 => $i,		
				});		
		}	
	}
	##################################

	my $ref = $c->request->params->{referer};
	
	$c->response->redirect($ref); 
	
	
	
}

sub obj_thing :Chained('base') :PathPart('obj_thing') :CaptureArgs(1) {
	my ($self, $c, $id ) = @_;
	
	$c->stash(obj_thing => $c->model('DB::Thing')->find({ id => $id }));
	
	$c->stash(error => "Object with $id not found") unless ($c->stash->{obj_thing});
		
	$c->log->debug("*** Object with id $id captured ***");
}

sub delete_thing :Chained('obj_thing') :PathPart('delete_thing') :Args(0) {
	my ($self, $c ) = @_;
	
	my $ref = $c->request->referer;
	$c->log->debug("*** referer is $ref ***");
	
	my @id;
	$id[0] = $c->stash->{obj_thing}->id;
	
	
	$c->forward( 'del_thing', \@id );
	
	$c->response->redirect($ref);
}
sub del_thing :Private {
	my ($self, $c, @id ) = @_;
	$c->log->debug("*** Inside del_thing method ***");
	my $thing = $c->model('DB::Thing')->find({ id => $id[0] });
	
	my $ref = $c->request->referer;
	my @thumbnails = $thing->thumb;
	
	foreach my $thumb (@thumbnails) {
		my $filename = $thumb->small;
		$filename =~ s{.+/}{};
		
		$c->log->debug("*** filename is $filename ***");
		my $small = "root/static/images/thumbnails/small/" . $filename;
		$c->log->debug("*** filename is $small ***");
		unlink $small;
		
		my $medium = "root/static/images/thumbnails/medium/" . $filename;
		unlink $medium;
		
		my $big = "root/static/images/thumbnails/big/" . $filename;
		unlink $big;
		
		$thumb->delete;		 
	}
	
	$thing->delete;
}
sub edit_thing :Chained('obj_thing') :PathPart('edit_thing') :Args(0) {
	my ( $self, $c ) = @_;

		$c->stash(
					template => 'manager/edit_thing.tt2',
					uri		=> "edit_thing_do",
					button	=> 'Փոխել',
					types		=> [ $c->model('DB::ThingType')->all()],	
					ref 		=> $c->request->referer,
						
				);
	
}

sub edit_thing_do :Chained('base') :PathPart('edit_thing_do') :Args(0) {
	my ($self, $c) = @_;
	$c->log->debug("*** Inside edit_thing_do method ***");
	
	my $ref	= $c->request->params->{referer};
	my $price 	 = $c->request->params->{price};
	my $discount = $c->request->params->{discount};
	my $type		 = $c->request->params->{type};
	my $info 	 = $c->request->params->{thing_info};
	
	my $thing_id = $c->request->params->{thing_id};
	my $shop 	 = $c->user->shop->id;
	
	my $editing = $c->model('DB::Thing')->find({ id => $thing_id });
	

	$editing->shop($shop);
	$editing->type($type);
	$editing->info($info);
	$editing->price($price);
	$editing->discount($discount);
	
	$editing->update;
	
	# Define thumbnails 
	##################################
	my @pic;
	 $pic[0] = $c->request->upload('pic0');
	 $pic[1] = $c->request->upload('pic1');
	 $pic[2] = $c->request->upload('pic2');
	# Define id's of thumbnails
	my @thumb;
	 $thumb[0] = $c->request->params->{thumbnail0};
	 $thumb[1] = $c->request->params->{thumbnail1};
	 $thumb[2] = $c->request->params->{thumbnail2};
	
	my $t = new Image::Magick::Thumbnail::Fixed; 
	
	foreach (my $i = 0; $i < 3; $i++) {
		if( $pic[$i] ) {
			$pic[$i]->copy_to('root/static/images');
			
			$c->log->debug("*** thumbnail id is $thumb[$i] ***");
			# Define thumbnails row
			my $editing_thumb = $c->model('DB::ThingThumbnail')->find({ id => $thumb[$i]});
			
			# Delete old thumbnails
			my $file = $editing_thumb->small;
			$file =~ s{.+/}{};
		
			$c->log->debug("*** filename is $file ***");
			my $small = "root/static/images/thumbnails/small/" . $file;
			$c->log->debug("*** filename is $small ***");
			unlink $small;
		
			my $medium = "root/static/images/thumbnails/medium/" . $file;
			unlink $medium;
		
			my $big = "root/static/images/thumbnails/big/" . $file;
			unlink $big;		
				
			# Get filename of uploaded file, and create corresponding image link
			
			my $filename = $pic[$i]->tempname;
			$filename =~ s{.+/}{};
			 
			# Create thumbnails 
		
			my $input = "root/static/images/" . $filename;
			my $output_small = "root/static/images/thumbnails/small/" . $filename;
			my $output_medium = "root/static/images/thumbnails/medium/" . $filename;
			my $output_big = "root/static/images/thumbnails/big/" . $filename;
			
			# Create small thumbnail
			$t->thumbnail(
							input => $input,
							output => $output_small,
							width => 60,
							height => 80,
							gravity => 'center',					
							);
			
			# Create medium thumbnail
			$t->thumbnail(
							input => $input,
							output => $output_medium,
							width => 300,
							height => 400,
							gravity => 'center',
							quality => '100'
							);
			
			# Create big thumbnail			
			$t->thumbnail(
							input => $input,
							output => $output_big,
							width => 900,
							height => 1200,
							gravity => 'center',
							quality => '100'
			);
			
			
			
			$editing_thumb->small($c->uri_for('../static/images/thumbnails/small/') . $filename);
			$editing_thumb->medium($c->uri_for('../static/images/thumbnails/medium/') . $filename);
			$editing_thumb->big($c->uri_for('../static/images/thumbnails/big/') . $filename);
			$editing_thumb->update;
			
			my $file2 = "root/static/images/" . $filename;
			unlink $file2;			

		}	
	}
	##################################

	
	
	$c->log->debug("*** referer is $ref ***");
	$c->response->redirect($ref);
	
	
}

######################
#		About CRUD		#
######################

sub edit_about :Chained('base') :PathPart('edit_about') :Args(0) {
	my ($self, $c ) = @_;
	$c->stash( 
				template => 'manager/edit_about.tt2',
				title 	=> "About",
				shop 		=> $c->user->shop,
				);
	
}


sub edit_about_do :Chained('base') :PathPart('edit_about_do') :Args(0) {
	my ( $self, $c ) = @_;
	
	
	
	my $info = $c->request->params->{brend_info};
	my $mail = $c->request->params->{mail};
	my $phone =	$c->request->params->{phone};
	my $site = $c->request->params->{site};
	my $address = $c->request->params->{address};
	my $social = $c->request->params->{social};
	my $country = $c->request->params->{country};
	
	my $logo = $c->request->upload('logo');
	my $link;
	if ($logo) {
		$logo->copy_to('root/static/images/logo');
		# Get filename of uploaded file, and create corresponding image link
			my $filename = $logo->tempname;
			$filename =~ s{.+/}{};
			
			$link = $c->uri_for('/static/images/logo/') . $filename;	
	}
	
	my $about = $c->model('DB::Shop')->find({ id => $c->user->shop->id });
	
	$about->info($info);
	$about->contact_mail($mail);
	$about->phone($phone);
	$about->site($site);
	$about->address($address);
	$about->social($social);
	$about->country($country);
	$about->logo($link);
	$about->update;
	
	
	$c->response->redirect($c->uri_for($self->action_for('edit_about')));
}

######################
#	Discount CRUD		#
######################

sub show_discounts :Chained('base') :PathPart('show_discount') :Args(0) {
	my ($self, $c) = @_;
	
	my $now = time;
	my @discounts = $c->model('DB::Discount')->all();
	for my $disc (@discounts) {
		if ($disc->active_till < $now && $disc->active_till ){
			$disc->delete;		
		}	
	}
	$c->stash(
				template => 'manager/show_discount.tt2',
				title 	=> "Զեղջեր",
				discounts => [$c->model('DB::Discount')->all],
				);
}

sub add_discount :Chained('base') :PathPart('add_discount') :Args(0) {
	my ($self, $c) = @_;
	
	$c->stash(
				template => 'manager/edit_discount.tt2',
				title 	=> 'Ավելացնել զեղջ',
				uri 		=> 'add_discount_do',
				button	=> 'Ավելացնել',
			
				);
}

sub add_discount_do :Chained('base') :PathPart('add_discount_do') :Args(0) {
	my ( $self, $c ) = @_;
	
	my $discount	 = $c->request->params->{discount};
	my $disc_type	 =	$c->request->params->{discount_type};
	my $col			 = $c->request->params->{collection};
	my $till 		 = $c->request->params->{active_till};
	
	
	my $active_till = $till * 86400 + time if $till;
	
	my $new_disc = $c->model('DB::Discount')->create({
		discount 	=> $discount,
		shop 			=> $c->user->shop->id,
		active_till => $active_till, 
		collection	=>	$col, 			
		});
	
	my @things = $c->model('DB::Thing')->search({ collection => $col });
	
	foreach my $thing (@things) {
		if( $disc_type == 1 ) {
			my $price = $thing->price();
			my $new_price = ((100-$discount)/100) * $price;
			$thing->discount($new_price);		
		}	
		else {
			$thing->discount($discount);		
		}
		$thing->update;		
	}
	
	$c->response->redirect($c->uri_for($self->action_for('show_discounts')));
}

sub obj_discount :Chained('base') :PathPart('obj_discount') :CaptureArgs(1) {
	my ($self, $c, $id ) = @_;
	
	$c->stash(obj_discount => $c->model('DB::Discount')->find({ id => $id }));
	
	$c->log->debug("*** Obj_discount with id $id captured ***");
	
}

sub delete_discount :Chained('obj_discount') :PathPart('delete_discount') :Args(0) {
	my ( $self, $c ) = @_;
	
	$c->stash->{obj_discount}->delete();
	
	$c->log->debug("*** Discount deletet ***");
	$c->response->redirect($c->uri_for($self->action_for('show_discounts')));
}

sub edit_discount :Chained('obj_discount') :PathPart('edit_discount') :Args(0) {
	my ($self, $c) = @_;
	
	$c->stash(
				template => 'manager/edit_discount.tt2',
				title 	=> 'Փոխել զեղջը',
				uri 		=> 'edit_discount_do',
				button	=> 'Փոխել',						
				);
}

sub edit_discount_do :Chained('base') :PathPart('edit_discount_do') :Args(0) {
	my ( $self, $c ) = @_;
	
	my $id 			 = $c->request->params->{obj_discount};
	my $discount	 = $c->request->params->{discount};
	my $disc_type	 =	$c->request->params->{discount_type};
	my $col			 = $c->request->params->{collection};
	my $till			 = $c->request->params->{active_till};
	
	my $active_till = $till * 86400 + time;
	
	my $edit_disc = $c->model('DB::Discount')->find({ id => $id });
	
	$edit_disc->discount($discount);
	$edit_disc->active_till($active_till); 
	$edit_disc->collection($col);
	$edit_disc->update; 	
	
	my @things = $c->model('DB::Thing')->search({ collection => $col });
	
	foreach my $thing (@things) {
		if($disc_type == 1 ) {
			my $price = $thing->price();
			my $new_price = ((100-$discount)/100) * $price;
			$thing->discount($new_price);		
		}	
		else {
			$thing->discount($discount);		
		}
		$thing->update;		
	}
	
	$c->response->redirect($c->uri_for($self->action_for('show_discounts')));
}

######################
#		Blog CRUD		#
######################

sub show_posts :Chained('base') :PathPart('show_posts') :Args(1) {
	my ($self, $c, $page) = @_;
	
	my $posts = $c->model('DB::ShopBlog')->search(undef, {order_by => { -desc => 'id' }});
	
	$posts = $posts->page($page);
	$posts->pager;	
	
	$c->stash(
				template => 'manager/show_posts.tt2',
				posts 	=> $posts,
				pager		=> $posts->pager,
				title		=> "Բլոգ",	
				);
				
}

sub add_post :Chained('base') :PathPart('add_post') :Args(0) {
	my ( $self, $c ) = @_;
	
	$c->stash( 	
		template => 'manager/edit_post.tt2',
		uri 		=> "add_post_do",
		button 	=> "Ավելացնել",
		title		=> "Ավելացնել գրառում",
		);
}

sub add_post_do :Chained('base') :PathPart('add_post_do') :Args(0) {
	my ( $self, $c ) = @_;
	
	my $header = $c->request->params->{header};
	my $post   = $c->request->params->{post};
	

	# Uploat thumbnail for this post
	
	my $upload = $c->request->upload('thumbnail');
	my $link;
	if ( $upload ) {	
		$upload->copy_to('root/static/images');
	
   	# Get filename of uploaded file, and create corresponding image link
		my $filename = $upload->tempname;
		$filename =~ s{.+/}{};
		$link = $c->uri_for('/static/images/') . $filename;	
	} else {
		$c->log->debug("*** Thumbnail not uploaded becouse :: $! ***");	
	}
	
	my $new_post = $c->model('DB::ShopBlog')->create({ 
		shop	 => $c->user->shop->id,		
		header => $header,
		post 	 => $post,
		thumbnail => $link,
		});
	
	# Create tags and associate them with posts
	
	my $tags = $c->request->params->{tags};	
	my @tags = split /,/, $tags;
	
	foreach my $tag (@tags) {
	
		# Delete start and end spaces in tags
		$tag =~ s/^\s*([ \w]+)\s*$/$1/;
		
		# If tag doesn't exists - create it
		my $new_tag = $c->model('DB::Tag')->find_or_new({
			tag => $tag,		
		});
		$new_tag->update_or_insert;
		
		# Associate that with post
		my $tag_id = $new_tag->id;			
		$new_post->create_related('blog_tags', { tag_id => $tag_id });
	} 
	
	$c->response->redirect($c->uri_for($self->action_for('show_posts'), 1));
} 

sub obj_post :Chained('base') :PathPart('obj_post') :CaptureArgs(1) {
	my ( $self, $c, $id ) = @_;
	
	$c->stash(obj_post => $c->model('DB::ShopBlog')->find({ id => $id }));
	$c->log->debug("*** Post with id $id captured ***");
}

# Delete captured post
sub delete_post :Chained('obj_post') :PathPart('delete_post') :Args(0) {
	my ($self, $c) = @_;
	
	$c->stash->{obj_post}->delete;
	$c->log->debug("*** Post deleted ");
	$c->response->redirect($c->uri_for($self->action_for('show_posts')));
}

# Show edit form for captured post
sub edit_post :Chained('obj_post') :PathPart('edit_post') :Args(0) {
	my ($self, $c) = @_;
	
	$c->log->debug("*** Inside edit_post method");
	$c->stash(
		uri 			=> 'edit_post_do',
		template 	=> 'manager/edit_post.tt2',
	
		button	 	=> "Փոխել",
		title 		=> "Փոփոխել գրառումը",
	)
}

# Edit capured post
sub edit_post_do :Chained('base') :PathPart('edit_post_do') :Args(0) {
	my ($self, $c) = @_;
	
	# Getting post
	my $header = $c->request->params->{header};
	my $post   = $c->request->params->{post};

	my $id 	  = $c->request->params->{obj_post};

	# Upload new thumbnail, if selected
	
	my $upload = $c->request->upload('thumbnail');
	my $link;
	if ( $upload ) {	
		$upload->copy_to('root/static/images');
	
   	# Get filename of uploaded file, and create corresponding image link
		my $filename = $upload->tempname;
		$filename =~ s{.+/}{};
		$link = $c->uri_for('/static/images/') . $filename;	
	} else {
		$c->log->debug("*** Thumbnail not uploaded becouse :: $! ***");	
	}	
	
	
	
	
	my $editing = $c->model('DB::ShopBlog')->find({ id => $id });
	
	$editing->header($header);
	$editing->post($post);
	$editing->thumbnail($link);
	$editing->date();
	$editing->update;
	
	# Create new tags
	my $tags = $c->request->params->{tags};
	
	if ( $tags ) {
		my @tags = split /,/, $tags;
		 
		foreach my $tag (@tags) {
	
			# Delete start and end spaces in tags
			$tag =~ s/^\s*([ \w]+)\s*$/$1/;
		
			# If tag doesn't exists - create it
			my $new_tag = $c->model('DB::Tag')->find_or_new({
				tag => $tag,		
			});
			$new_tag->update_or_insert;
		
			# Associate that with post
			my $tag_id = $new_tag->id;			
			$editing->create_related('blog_tags', { tag_id => $tag_id });
		}  	
	} 
	
	# Delete old tags(tags that user select)
	my @del_tags = $c->request->params->{old_tag};
	
	for my $del_tag (@del_tags) {
		$editing->delete_related('blog_tags', { tag_id=> $del_tag });	
	}
	

	
	$c->response->redirect($c->uri_for($self->action_for('show_posts'), 1) );
}


###############################
#		Additional Functions		#
###############################

=head1 AUTHOR

Tigran,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
