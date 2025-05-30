// view_customizations.js
$(document).ready(function() {
  // 1. Reorder project tabs (within #main-menu)
  var $tabs = $('#main-menu ul');
  var $overview = $tabs.find('a.overview').parent();
  var $issues   = $tabs.find('a.issues').parent();
  var $contacts = $tabs.find('a.contacts').parent();
  if ($overview.length && $issues.length && $contacts.length) {
    $overview.detach();
    $issues.detach();
    $contacts.detach();
    $tabs.prepend($contacts).prepend($issues).prepend($overview);
  }

    // 2. Rewrite author line to show 'am' and 'Am' with absolute timestamps
  $('p.author').each(function() {
    var $p = $(this);
    var authorLink = $p.find('a.user').first();
    var authorHtml = authorLink.prop('outerHTML');
    var links = $p.find('a[title]');
    if (links.length >= 2) {
      var added = links.eq(0).attr('title');
      var updated = links.eq(1).attr('title');
      var newHtml = authorHtml + ' am ' + added + ' hinzugefügt. Am ' + updated + ' aktualisiert.';
      $p.html('Von ' + newHtml);
    }
  });

  // 3. Move Thema (CF id=1) and Unterthema (CF id=2) to top of issue form Move Thema (CF id=1) and Unterthema (CF id=2) to top of issue form
  var $container = $('#all_attributes');
  var $thema      = $('#issue_custom_field_values_1').closest('p');
  var $unterthema = $('#issue_custom_field_values_2').closest('p');
  if ($thema.length && $unterthema.length) {
    $thema.prependTo($container);
    $unterthema.insertAfter($thema);
  }

  // 4. Re-enable Contacts autocomplete on custom-field inputs
  if (window.rm && rm.AutoComplete && $.ui && $.ui.autocomplete) {
    $('input[data-auto-complete-url*="contacts"]').autocomplete({
      source: function(request, response) {
        var url = this.element.data('auto-complete-url');
        $.getJSON(url + '&q=' + request.term, response);
      },
      minLength: 2
    });
  }
});
