import _ from 'lodash';
import AggTypesBucketsBucketAggTypeProvider from 'ui/agg_types/buckets/_bucket_agg_type';
import AggTypesBucketsCreateFilterTermsProvider from 'ui/agg_types/buckets/create_filter/terms';
import orderAndSizeTemplate from 'ui/agg_types/controls/order_and_size.html';
export default function SignificantTermsAggDefinition(Private) {
  var BucketAggType = Private(AggTypesBucketsBucketAggTypeProvider);
  var createFilter = Private(AggTypesBucketsCreateFilterTermsProvider);

  return new BucketAggType({
    name: 'significant_terms',
    title: 'Significant Terms',
    makeLabel: function (aggConfig) {
      return 'Top ' + aggConfig.params.size + ' unusual terms in ' + aggConfig.params.field.displayName;
    },
    createFilter: createFilter,
    params: [
      {
        name: 'field',
        filterFieldTypes: 'string'
      },
      {
        name: 'size',
        editor: orderAndSizeTemplate,
      },
      {
        name: 'exclude',
        type: 'regex',
        advanced: true
      },
      {
        name: 'include',
        type: 'regex',
        advanced: true
      }
    ]
  });
};
