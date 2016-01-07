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

var priceListApp = angular.module('priceListApp', [])
var priceListCrtl = priceListApp.controller('PriceListController', ['$scope', '$http', function($scope, $http) {
  $scope.admin_mode = false;
  $scope.currentItemIndex = -1;
  $scope.new_item_url = '';

  $scope.applyItemI18n = function(item) {
    item.updated_at = new Date(item.updated_at).toString('M.d.yyyy, HH:mm');
    if (item.last_price !== null)
      item.last_price.price = numeral(parseFloat(item.last_price.price)).format('0.00');

    jQuery(item.last_price_changes).each(function(index, price) {
      price.created_at = new Date(price.created_at).toString('M.d.yyyy, HH:mm');
      price.price = numeral(parseFloat(price.price)).format('0.00')
    });
    return;
  };

  $http.get('v1/items/available.json').then(function(response) {
    jQuery(response.data).each(function(index, item) {
      $scope.applyItemI18n(item);
    });
    $scope.items = response.data;
  });

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

  $scope.detailedInfosFor = function(item) {
    $scope.currentItemIndex = jQuery($scope.items).index(item);
  };

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
      url: url
    }).then(function(response) {
      $scope.items.push(response.data);
      jQuery('input#itemUrl').val('');
      jQuery('#addItem').button('reset');
    }, function(response) {
      alert(response.statusText + '\n' + response.data);
      jQuery('#addItem').button('reset');
    });
  };
}]);
