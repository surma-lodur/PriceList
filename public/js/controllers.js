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

  $http.get('api/items/available.json').success(function(data) {
    jQuery(data).each(function(index, item) {
      item.updated_at = new Date(item.updated_at).toString('M.d.yyyy, HH:mm');

      jQuery(item.last_price_changes).each(function(index, price) {
        price.created_at = new Date(price.created_at).toString('M.d.yyyy, HH:mm');
        price.price = numeral(parseFloat(price.price)).format('0.00')
      });
    });
    console.log(data);
    $scope.items = data;
  });

}]);
