using System;
using System.Collections.Generic;
using System.Text;

namespace eVetCare.Model.SearchObjects
{
    public class ServiceCategorySearchObject : BaseSearchObject
    {
        public int CategoryId { get; set; }

        public string Name { get; set; } = null!;

        public bool? IsDeleted { get; set; }

    }
}
