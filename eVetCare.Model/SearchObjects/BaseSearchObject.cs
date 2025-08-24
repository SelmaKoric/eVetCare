using System;
namespace eVetCare.Model.SearchObjects
{
    public class BaseSearchObject
    {
        public int? Page { get; set; }
        public int? PageSize { get; set; }

        public bool IncludeInactive { get; set; }
        public bool OnlyInactive { get; set; }
    }
}