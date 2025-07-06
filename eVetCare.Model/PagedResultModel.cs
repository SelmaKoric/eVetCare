using System;
using System.Collections.Generic;

namespace eVetCare.Model
{
        public class GetPaged<T>
        {
            public int? Count { get; set; }
            public IList<T> ResultList { get; set; }
            public List<T> Result { get; set; }
            public int Page { get; set; }
            public int PageSize { get; set; }

        }
}

