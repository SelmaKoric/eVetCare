using System;
using System.Collections.Generic;

namespace eVetCare.Model
{
	public class ServiceUsage
	{
        public int ServiceId { get; set; }
        public string ServiceName { get; set; } = string.Empty;
        public int UsageCount { get; set; }

    }
}

