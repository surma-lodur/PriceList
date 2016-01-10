numeral.language('de', {
  delimiters: {
    thousands: '.',
    decimal: ','
  },
  abbreviations: {
    thousand: 't',
    million: 'mrd',
    billion: 'mio',
    trillion: 'tri'
  },
  ordinal: function(number) {
    return number === 1 ? 'er' : 'ème';
  },
  currency: {
    symbol: '€'
  }
});
numeral.language('de');

var priceListApp = angular.module('priceListApp', []);

// Register ellipsis attribute to concatenate too log texts
priceListApp.directive('ellipsis', [function() {
  return {
    required: 'ngBind',
    restrict: 'A',
    priority: 100,
    link: function($scope, element, attrs, ctrl) {
      $scope.hasEllipsis = false;
      $scope.$watch(element.html(), function(value) {
        if (!$scope.hasEllipsis) {
          // apply ellipsis only one
          $scope.hasEllipsis = true;
          element.dotdotdot({
            wrap: 'letter',
            height: 20,
            //watch: $(this)
          });
        }
      });
    }
  };
}]);

var priceListCrtl = priceListApp.controller('PriceListController', ['$scope', '$http', function($scope, $http) {
  $scope.admin_mode = false;
  $scope.currentItemIndex = -1;
  $scope.new_item_url = '';
  $scope.current_list;
  $scope.localized_price_sum;
  $scope.localized_currency_sum;

  // will be changed to list items or listless items
  $scope.items = [];

  // Covnert Formats in localized formats
  $scope.applyItemI18n = function(item) {
    item.updated_at = new Date(item.updated_at).toString('MM.dd.yyyy, HH:mm');
    if (item.last_price !== null) {
      item.last_price.price_raw = item.last_price.price;
      item.last_price.price = numeral(parseFloat(item.last_price.price)).format('0.00');
    }

    jQuery(item.last_price_changes).each(function(index, price) {
      price.created_at_raw = new Date(price.created_at);
      price.price_raw = price.price;
      price.created_at = new Date(price.created_at).toString('MM.dd.yyyy, HH:mm');
      price.price = numeral(parseFloat(price.price)).format('0.00');
    });
    return;
  };

  $http.get('v1/lists/available/with_items.json').then(function(response) {
    jQuery(response.data).each(function(index, list) {
      jQuery(list.available_items).each(function(index, item) {
        $scope.applyItemI18n(item);
      });
    });
    $scope.lists = response.data;
  });

  // get initial items without list
  $http.get('v1/items/available/without_list.json').then(function(response) {
    jQuery(response.data).each(function(index, item) {
      $scope.applyItemI18n(item);
    });
    $scope.items_without_list = response.data;
    $scope.items = $scope.items_without_list;
    $scope.setPriceSummary();
  });

  $scope.setPriceSummary = function() {
    $scope.localized_price_sum = 0.0;
    jQuery($scope.items).each(function(index, item) {
      if (item.last_price !== null){
        $scope.localized_currency_sum = item.last_price.currency;
        $scope.localized_price_sum += parseFloat(item.last_price.price_raw);
      }
    });
    $scope.localized_price_sum = numeral(parseFloat($scope.localized_price_sum)).format('0.00');
    return;
  }

  $scope.gainAdminPrivileges = function() {
    $http.get('admin/v1/authorize').then(function(response) {
      $scope.admin_mode = true;
    }, function(response) {
      alert(response.statusText + '\n' + response.data);
    });
  };

  $scope.adminActiveClass = function() {
    if ($scope.admin_mode) {
      return 'active';
    } else {
      return '';
    }
  };

  $scope.tabActiveClass = function(list) {
    if (list == $scope.current_list) {
      return 'active';
    }
    return;
  }

  $scope.setCurrentList = function(list) {
    $scope.current_list = list;
    if (list === null || list === undefined) {
      $scope.items = $scope.items_without_list;
    } else {
      $scope.items = list.available_items;
    }
    $scope.setPriceSummary();
    return;
  }

  //*************
  // Item methods
  //*************

  $scope.detailedInfosFor = function(item) {
    $scope.currentItemIndex = jQuery($scope.items).index(item);
    return;
  };

  $scope.editCurrentItem = function(list) {
    var edit_item = $scope.items[$scope.currentItemIndex];
    if (list !== null || list !== undefined) {
      if (edit_item.list_id === list.id)
        return;
      edit_item.list_id = list.id
      list.available_items.push(edit_item);
    } else {
      if (edit_item.list_id === null || edit_item.list_id === undefined)
        return;
      edit_item.list_id = null
      $scope.items_without_list.push(edit_item);
    }

    $scope.items.splice($scope.currentItemIndex, 1);
    $scope.updateItem(edit_item);
    return;
  }

  $scope.deleteItem = function(item) {
    $http.delete('admin/v1/items/' + item.id + '.json').then(function(response) {
      $scope.items.splice(jQuery($scope.items).index(item), 1);
    }, function(response) {
      alert(response.statusText + '\n' + response.data);
    });
  };

  $scope.createItem = function(url) {;
    jQuery('#addItem').button('loading');
    $http.post('admin/v1/items.json', {
      url: url,
      list_id: $scope.current_list.id
    }).then(function(response) {
      $scope.applyItemI18n(response.data);
      $scope.items.push(response.data);
      jQuery('input#itemUrl').val('');
      jQuery('#addItem').button('reset');
    }, function(response) {
      alert(response.statusText + '\n' + response.data);
      jQuery('#addItem').button('reset');
    });
  };

  $scope.updateItem = function(item) {;
    $http.put('admin/v1/items/' + item.id + '.json', {
      list_id: item.list_id
    }).then(function(response) {
      jQuery('.modal').modal('hide');
    }, function(response) {
      alert(response.statusText + '\n' + response.data);
    });
  };

  //*************
  // List methods
  //*************

  $scope.deleteList = function(list) {
    $http.delete('admin/v1/lists/' + list.id + '.json').then(function(response) {
      $scope.lists.splice(jQuery($scope.lists).index(list), 1);
    }, function(response) {
      alert(response.statusText + '\n' + response.data);
    });
  };

  $scope.createList = function(title) {
    jQuery('#createList').button('loading');
    $http.post('admin/v1/lists.json', {
      title: title
    }).then(function(response) {
      $scope.lists.push(response.data);
      jQuery('input#newListTitle').val('');
      jQuery('#createList').button('reset');
    }, function(response) {
      alert(response.statusText + '\n' + response.data);
      jQuery('#createList').button('reset');
    });
  };
}]);
