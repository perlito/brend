$(function(){ 
	// Publish post in home?
	if( ! $('textarea[name=lead]').val()) {
	$('#home_text').toggle();
	}
	$('input:checkbox').change(function(){
		$('#home_text').toggle();
			
		});
	
	$('form').submit(function(){
		
		// Check header
		if (! $('input[name="header"]').val()) {
			$('#header_error').html('Заголовок забыл');
			return false;	
			} 
			
		// Check textarea
		if(! $('textarea[name="post"]').val()) {
			$('#textarea_error').html('Забыл собственно пост');
			return false;			
			}
		
		// Check selected rubric
		if ( $('select').val() == 0 ) {
			$('#select_error').html('Забыл рубрику');
			return false; 			
			} 

		// Checkbox validation
		if( $('input:checked').val() && ! $('textarea[name=lead]').val()){
			$('#obzor').focus();
			$('#lead_error').html('Обзор забыл');
			return false;		
			}
		if ( $('input:checked').val() && !$('input[name=thumbnail]').val() ) {

			$('#thumb_error').html('На главной картинка нужна');
			return false;	
			}
		
		
		return true;		
		});
		
 });
 

