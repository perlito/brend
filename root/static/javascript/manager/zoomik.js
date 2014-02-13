$(function(){
		$('.thumbnail').mouseover(function(){
			
		var $src = $(this).children('img').attr('medium');
		
		if( $src ) {
			
			$(this).append(
				'<img src="'+$src+'" class="zoomik" width="180" height="240" >'
				);
			}
		});
		$('.thumbnail').mouseout(function(){
			$('.zoomik').remove();		
		});
	});