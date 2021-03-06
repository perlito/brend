package brend::Controller::Login;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

brend::Controller::Login - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut


sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
	 
	 my $username = $c->request->params->{username};
	 my $password = $c->request->params->{password};
	 
	 if ( $username && $password ) {
		if ( $c->authenticate({
										username => $username,
										password => $password,				
										}) ) {
									
							return 1;				
						} 
		else {
							return 0;						
						} 	 
	 } 
	 else {
		return 0;	 
	 } 
	$c->stash(template => 'loggedin.tt2');
}

sub admin :Local :Args(0) {
	 my ( $self, $c ) = @_;
	 
	 
	 $c->stash( wrapper => 'login_wrapper.tt2' );	 
	 my $username = $c->request->params->{username};
	 my $password = $c->request->params->{password};

		$c->log->debug('*** inside admin of login ***');
	 	 
	 if ( $username && $password ) {
		
		if( $c->authenticate({
									username => $username,
									password => $password,						
										}) ) {
				$c->response->redirect($c->uri_for('/admin'));
				$c->log->debug("*** admin enter ***")				
				} else {
					$c->log->debug("*** Wrong username or password ***");

			
				}
		}
		else {

			$c->log->debug("*** Empty username or password ***");	
		}	 
	 
	 
	 $c->stash( template => 'admin/login.tt2', title => "login" );	
}

sub manager :Local :Args(0) {
	    my ( $self, $c ) = @_;
	 
	 $c->stash( wrapper => 'login_wrapper.tt2' );	 
	 my $username = $c->request->params->{username};
	 my $password = $c->request->params->{password};
	 
		$c->log->debug('*** inside manager of login ***');
	 	 
	 if ( $username && $password ) {
		
		if( $c->authenticate({
									username => $username,
									password => $password,						
										}) ) {
		
				$c->log->debug("*** manager $username Logged in ***");	
				$c->response->redirect($c->uri_for('/manager'));				
				} else {

					$c->log->debug("*** manager $username not Logged in ***");			
				}
		}
		else {
				$c->log->debug("*** manager not Logged in ***");	
		}	 
	 
	 
	 $c->stash( template => 'manager/login.tt2', title => "login" );	
}

sub user_login :Local Args(2) {
	my ( $self, $c, $username, $password) = @_;
	
	

	 
	 if ( $username && $password ) {
		if ( $c->authenticate({
										username => $username,
										password => $password,				
										}) ) {
							$c->stash(
							wrapper => 	'',						
							template => 'loggedin.tt2');
				         
							$c->log->debug('*** Logged in ***');		
							return 1;				
						} 
		else {
							return 0;						
						} 	 
	 } 
	 else {
		return 0;	 
	 } 
	

}

=head1 AUTHOR

Tigran,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
