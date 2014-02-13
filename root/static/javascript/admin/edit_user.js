$(function(){	
	$('#manager_shop').hide();
	$('select').change(function(){
		if ($(this).val() == 4 ){
				$('#manager_shop').show();			
			}
		else {
			$('#manager_shop').hide();			
			}		
		});
	
	$('form').submit(function(){
			
		// Check username field
		var $username = $('input[name=username]').val();
			
		if( /\W/.test($username) || ! $username){
			$('#username_error').html('Такого логина не бывает(допустимы буквы, цифры, и знак _)');	
			return false;		
			}
		
		// Check email field
		var $mail = $('input[name=mail]').val();

		if( ! /^.+?@\w+?\.\w\w\w?$/.test($mail) || ! $mail ) {
			$('#mail_error').html('Не похоже на почтовый адрес');
			return false;
			}
		// Check passwords
		var $pass1 = $('input[name=password]').val();
		var $pass2 = $('input[name=retype_pass]').val();
		if ( $pass1 != $pass2 || $pass1.length < 8){
			$('#pass_error').html('Пароли должны быт не менее 8-и символов,<br>совпадать и содержать буквы');
			return false;			
			}
		
		if($('select').val() == 4 &&  $('input[name=shop]').val() == '' ) {
			$('#manager_error').html('Введите имя магазина менеджера');
			return false;
			} 
			return true;
	});
		
});











