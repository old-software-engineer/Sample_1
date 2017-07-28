$(document).ready(function () {

  $('#destroy-avatar').click(function(){
    $('.avatar-edit').html('<input type="file" id="user_avatar" name="user[avatar]">');
  });

  if ($('.contact-box').length > 0) {

    acceptRoleFilter($('#filterByRole').val());

    $('.contact-box').each(function () {
      animationHover(this, 'pulse');
    });

    $('#filterByRole').change(function(){
      acceptRoleFilter($(this).val());
    });
  }

  $('.clients-list .other-users input:checked').parents("tr").addClass("checked");

  $('.clients-list .other-users input[type=checkbox]').on('ifClicked', function(event) {
    $(this).parents("tr").toggleClass("checked", !$(this).prop("checked"));
  });

  $('.clients-list .other-users tr').click(function() {
    $(this).find("input").iCheck('toggle');
    $(this).toggleClass("checked", $(this).find("input").prop("checked"));
  });

  function acceptRoleFilter(role){
    if (parseInt(role)) {
      $('.contact-item').hide();
      $('.contact-item[data-role="' + role + '"]').show();
    } else {
      $('.contact-item').show();
    }
  }

  $('.new-contract').click(function(event){
    event.preventDefault();
    var user_id = $(this).data("user_id");

    if (user_id > 0) {
      $.post("/contracts", {contract: {user_id: user_id}}, function(data) {
        console.log(data);
      });
    } else {
      console.log("User id error");
    }

  });

  // Template fields

  $('#template-preview').click(function(event){
    $('#preview-box').html('<div class="spinner"><i class="fa fa-spinner fa-spin fa-4x"></i></div>');
    $.post("/templates/preview", {body: $('#template-body').val()});
  });

  var fieldsBox = $('.fields-box').html();;

  $("#show-field-controls").click(function(event){
    $(".field-controls").show();
    $(this).hide();
    $('#save-field-controls').show();
    $('#cancel-field-controls').show();
    $('#add-field-item').show();
    $('#add-field-item .field-key').prop('readonly', false);
  });

  $("#cancel-field-controls").click(function(event){
    $('.fields-box').html(fieldsBox);
    $('#save-field-controls').hide();
    $('#cancel-field-controls').hide();
    $('#show-field-controls').show();
  });

  $("#save-field-controls").click(function(event){
    $('#save-field-controls').hide();
    $('#cancel-field-controls').hide();
    $('.field-key').prop('readonly', true);
    $(".field-controls").hide();
    $('#show-field-controls').show();
    if($('#add-field-item').find('.field-key').val() == ""){$('#add-field-item').hide();};
  });

  $(document).on('click', "#new-field", function(event){
    event.preventDefault();
    var field_index = 0 || $('.field-item').length;
    var fieldItem = $(this).parents('#add-field-item');
    var key = fieldItem.find('.field-key').val().toUpperCase();
    var template_id = fieldItem.find('> input').val();
    var error = false;

    $('.field-key').not(":hidden").not(":last").each(function(index, field){
      if (key == $(field).val()) {
        alert("Field already exist");
        error = true;
      }
    });

    if (!error) {
      $('<div class="field-item clearfix">' + 
          '<div class="col-sm-12">' +
            '<input type="text" id="signme_template_fields_attributes_' + field_index + '_label" name="signme_template[fields_attributes][' + field_index + '][key]" value="' + key + '" class="form-control field-key">' + 
          '</div>' +
          '<div class="field-controls" style="display:block;">' + 
            '<a id="remove-field" href="#"><i class="fa fa-minus"></i></a>' + 
          '</div>' +
          '<input type="hidden" id="signme_template_fields_attributes_' + field_index + '_template_id" name="signme_template[fields_attributes][' + field_index + '][template_id]" value="' + template_id + '">' +
        '</div>').insertBefore('#add-field-item');
    }

    fieldItem.find('.field-key').val('');
  });

  $(document).on('click', "#remove-field", function(event){
    removeField($(this).parents('.field-item'));
  });

  $('#template-contract').click(function(event){
    var iframe = document.getElementById('preview-frame')
    iframe.src = iframe.src;
  });

  $(document).on('change', '#signme_contract_template_id', function(){
    var template_id = $(this).val();
    $.get("/contracts/fields", {template_id: template_id});
  });

  function removeField(field) {
    field.hide();
    
    if (field.find('.field-destroy').length > 0) {
      field.find('.field-destroy').val(1);
    } else {
      field.find("input").prop("disabled", true)
    }
  }

  $(document).on('keydown', '#customer-info input', function(){
    var input = $(this);
    $('#card input[name="' + input.attr('name') + '"]').val(input.val());
    $('#paypal input[name="' + input.attr('name') + '"]').val(input.val());
  });

  $('#edit-contract').click(function(event){
    url = $(this).data('url')
    $.ajax({
       type: 'get',
       url: url,
       success : function(response) {
         $("#contract-editor-box").html(response);
       },
       error : function() {
           alert('Something went wrong.');
       },
       beforeSend: function(){
       }
     });
  });
});
