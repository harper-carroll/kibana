define(function (require) {
    var app = require('modules').get('app/dashboard');
    var _ = require('lodash');
    var datemath = require('utils/datemath');
    var moment = require('moment');
    var angular = require('angular');

    var timefilter = require('components/timefilter/timefilter');
    app.factory('searchAuditor', function (elasticSearchFields, 
      Restangular, timefilter) {
         var FORMAT_STRING = 'YYYY/MM/DD HH:mm:ss';

         var previousQuery = {
             query    : '',
             fromDate : '',
             toDate   : ''
         };
        var formatQuery = function(query) {
            var _query = _.isArray(query) ? query : [query];
            if (_.isArray(_query)) {
                var count = 0;
                _.each(_query, function($q) {
                    $q = elasticSearchFields.convertQuery($q);
                    _query[count] = $q;
                    ++count;
                });

            } else {
                _query = elasticSearchFields.convertQuery(_query);
            }
            return _query;
        };
        
        var logQuery = function(query) {
            // ignore these searches for search auditing
            
            var timeFrom = datemath.parse(timefilter.time.from);
            var timeTo = datemath.parse(timefilter.time.to);
                            
            if (!timeFrom || !timeTo || 
                query === '' || 
                query === '*') {
                return;
            }
            
            timeFrom = moment(timeFrom).format(FORMAT_STRING);
            timeTo = moment(timeTo).format(FORMAT_STRING);
            
            if (query === previousQuery.query &&
                timeFrom === previousQuery.fromDate &&
                timeTo === previousQuery.toDate) {
                return;
            }
            previousQuery = {
                query    : query,
                fromDate : timeFrom,
                toDate   : timeTo
            };
            Restangular
                .all('audit/')
                .post({
                    query    : query,
                    from     : timeFrom,
                    to       : timeTo
                })
                .then(function(response){
                    if (response.error){
                        var error = response.message || 'An unknown error occured';
                        console.log('Search Audit Error:', error);
                    }
                });
        };
        
        return {
            logAndCapitalize : function(stateObj) {
                var capitalizedQuery = formatQuery(stateObj.query.query_string.query)[0];
                logQuery(capitalizedQuery);
                // seems like we need a deep copy to force angular to reflect the
                // query change in the view
                var newState = angular.copy(stateObj);
                newState.query.query_string.query = capitalizedQuery;
                return newState;
            }

        };
    });
});
