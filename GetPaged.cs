// Plan (pseudocode):
// - Create a generic GetPaged<T> class in the eVetCare.Services namespace.
// - Include properties used by AppointmentService.GetPaged: Count, Result, Page, PageSize.
// - Ensure List<T> is initialized to avoid null refs.
// - Add necessary using directives.
// - This resolves CS0246 by providing the missing type.

using System.Collections.Generic;

namespace eVetCare.Services
{
    public class GetPaged<T>
    {
        public int? Count { get; set; }
        public List<T> Result { get; set; } = new();
        public int Page { get; set; }
        public int PageSize { get; set; }
    }
}
