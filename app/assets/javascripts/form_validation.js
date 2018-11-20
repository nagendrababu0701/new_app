$( document ).ready(function() {
    //Form validations for Login and Sign up page starts /////////////////////////
	
	//Form validations for common fields present in Login and Sign up pages both starts here //////////////////
	//Check the Email field in Login and Sign up page
	$('#user_email').on('keyup', function() {
		var input=$(this);
		
		//Check if email field is blank
		var is_email_blank=input.val();
		
		//Check if valid email field
		var re = /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/;
		var is_email=re.test(input.val());
		
		if(is_email_blank){input.removeClass("invalid").addClass("valid");$('.error_email').html(""); $('.error_submit').html("");}
		else{input.removeClass("valid").addClass("invalid");$('.error_email').html("Please fill the email address."); return;}
		
		if(is_email){input.removeClass("invalid").addClass("valid"); $('.error_email').html(""); $('.error_submit').html("");}
		else{input.removeClass("valid").addClass("invalid");$('.error_email').html("Please enter valid email address.");}
	});
		
	//Check the Password field in Login and Sign up page
	$('#user_password').on('keyup', function() {
		var input=$(this);
		var is_name=input.val();
		var len=input.val().length;
		
		//Check if password field is blank
		if(is_name){input.removeClass("invalid").addClass("valid");$('.error_pass').html(""); $('.error_submit').html("");}
		else{input.removeClass("valid").addClass("invalid");$('.error_pass').html("Please enter the password.");}
		
		//In Sign up page check if the minlength of password
		var  form_hasClass = $(this).parents("form").hasClass("new_user");
		if(form_hasClass && len < 6){
			input.removeClass("valid").addClass("invalid");$('.error_pass').html("Please enter the password with minimum 6 characters.");
		}//endif
	});
	//Form validations for common fields present in Login and Sign up pages both ends here //////////////////
	
	/////////////////////////////////////////////////////////////////////////////
	//Form validations for Sign up pages starts here //////////
	//Check the Lanid field in Sign up page
	$('#user_lanid').on('keyup', function() {
		var input=$(this);
		var is_name=input.val();
		
		//Check if lanid field is blank
		if(is_name){input.removeClass("invalid").addClass("valid");$('.error_lanid').html(""); $('.error_submit').html("");}
		else{input.removeClass("valid").addClass("invalid");$('.error_lanid').html("Please enter the Lanid.");}
	});
	//Check the First name field in Sign up page
	$('#user_first_name').on('keyup', function() {
		var input=$(this);
		var is_name=input.val();
		
		//Check if first name field is blank
		if(is_name){input.removeClass("invalid").addClass("valid");$('.error_first_name').html(""); $('.error_submit').html("");}
		else{input.removeClass("valid").addClass("invalid");$('.error_first_name').html("Please enter the First name.");}
	});
	//Check the Last name field in Sign up page
	$('#user_last_name').on('keyup', function() {
		var input=$(this);
		var is_name=input.val();
		
		//Check if last name field is blank
		if(is_name){input.removeClass("invalid").addClass("valid");$('.error_last_name').html(""); $('.error_submit').html("");}
		else{input.removeClass("valid").addClass("invalid");$('.error_last_name').html("Please enter the Last name.");}
	});
	
	//Check the Password Confirmation field in Sign up page
	$('#user_password_confirmation').on('keyup', function() {
		var input=$(this);
		var is_name=input.val();
		
		//Check if password confirmation field is blank
		if(is_name){input.removeClass("invalid").addClass("valid");$('.error_confirm_pass').html(""); $('.error_submit').html("");}
		else{input.removeClass("valid").addClass("invalid");$('.error_confirm_pass').html("Please enter password Confirmation.");}
		
		//Check if password confirmation field is not same as password
		if($("#user_password").val() == $("#user_password_confirmation").val()){input.removeClass("invalid").addClass("valid");$('.error_confirm_pass').html(""); $('.error_submit').html("");}
		else{input.removeClass("valid").addClass("invalid");$('.error_confirm_pass').html("Password Confirmation does not match.");}
	});
	//Form validations for Sign up pages starts here //////////
	
	

	// After Login Form Submitted Validation
	$(".btn-success").on('click',function(event){
		var form_data=$("#new_user").serializeArray();
		var error_free=true;
		
		var valid= $('#user_email').hasClass("valid");
		if (!valid){error_free=false;}
		
		var valid= $('#user_password').hasClass("valid");
		if (!valid){error_free=false;}
		
		if (!error_free){
			event.preventDefault();
			$('.error_submit').html("Please fill valid inputs.");
		}else{
			$('.error_submit').html("");
			//alert("Submitting the entries.");
		}
	});
	
	// After Sign up Submitted Validation
	$(".btn-info").on('click',function(event){	
		var error_free=true;
		
		var valid= $('#user_lanid').hasClass("valid");
		if (!valid){error_free=false;}
			
		var valid= $('#user_email').hasClass("valid");
		if (!valid){error_free=false;}
		
		var valid= $('#user_first_name').hasClass("valid");
		if (!valid){error_free=false;}
		
		var valid= $('#user_last_name').hasClass("valid");
		if (!valid){error_free=false;}
		
		var valid= $('#user_password').hasClass("valid");
		if (!valid){error_free=false;}
		
		var valid= $('#user_password_confirmation').hasClass("valid");
		if (!valid){error_free=false;}
		
		
		if (!error_free){
			event.preventDefault();
			$('.error_submit').html("Please fill valid inputs.");
		}else{
			$('.error_submit').html("");
			//alert("Submitting the entries.");
		}
	});
	//Form validations for Login and Sign up page ends /////////////////////////


	//Form validations for Project Creation page starts /////////////////////////
	//Check the Project Name field
	$('#project_project_name').on('keyup', function() {
		var input=$(this);
		
		//Check if project name field is blank
		var is_project_blank=input.val();
		
		//Check if valid project name entered
		var re = /^[a-z0-9-]+$/;
		var is_project=re.test(input.val());
		
		if(is_project_blank){input.removeClass("invalid").addClass("valid");$('.error_project').html("");}
		else{input.removeClass("valid").addClass("invalid");$('.error_project').html("Please fill the project name."); return;}
		
		if(is_project){input.removeClass("invalid").addClass("valid");  $('.error_project').html("");}
		else{input.removeClass("valid").addClass("invalid");$('.error_project').html("Project names may only contain lower-case letters, numbers, and dashes.");}
	});
	
	// //Check the Environment field
	$('#project_env').on('blur', function() {
		var input=$(this);
		
		//Check if environment field is selected
		var env=input.val();
		
		if(env){input.removeClass("invalid").addClass("valid");  $('.error_env').html("");}
		else{input.removeClass("valid").addClass("invalid");$('.error_env').html("Please select an environment.");}
	});
	
	// //Check the Database field
	$('#project_db_name').on('blur', function() {
		var input=$(this);
		
		//Check if project name field is blank
		var db=input.val();
		
		if(db){input.removeClass("invalid").addClass("valid");  $('.error_db').html("");}
		else{input.removeClass("valid").addClass("invalid");$('.error_db').html("Please select a database.");}
	});
	
	
	// // Create Project btn submit Validation
	$(".btn-create-project").on('click',function(event){	
		var error_free=true;
		
		var valid= $('#project_project_name').hasClass("valid");
		if (!valid){error_free=false;}
			
		var valid= $('#project_env').hasClass("valid");
		if (!valid){error_free=false;}
		
		var valid= $('#project_db_name').hasClass("valid");
		if (!valid){error_free=false;}

		if (!error_free){
			event.preventDefault();
			$('.error_submit').html("Please fill valid inputs.");
		}else{
			$('.error_submit').html("");
			//alert("Submitting the entries.");
		}
	});
	//Validations checks for create project submit btn ////
	
	
	//Form validations for Project Creation page ends /////////////////////////
});
