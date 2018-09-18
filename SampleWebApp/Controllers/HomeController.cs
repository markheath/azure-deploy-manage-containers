using Microsoft.AspNetCore.Mvc;
using System.Text.Encodings.Web;
using Microsoft.Extensions.Configuration;
using Microsoft.AspNetCore.Hosting;
using System.Net.Http;
using System.IO;
using System.Threading.Tasks;
using System;

namespace SampleWebApp.Controllers
{
    public class HomeController : Controller
    {
        private readonly IConfiguration config;
        private readonly IHostingEnvironment hostingEnv;
        private readonly IHttpClientFactory httpClientFactory;
        public HomeController(IConfiguration config, IHostingEnvironment hostingEnv,
            IHttpClientFactory httpClientFactory)
        {
            this.config = config;
            this.hostingEnv = hostingEnv;
            this.httpClientFactory = httpClientFactory;
        }

        public async Task<IActionResult> Index()
        {
            var viewModel = new IndexViewModel();
            viewModel.EnvironmentName = hostingEnv.EnvironmentName;
            viewModel.HostName = System.Net.Dns.GetHostName();
            viewModel.TestSetting = config["TestSetting"];
            viewModel.TestFile = "<NOT FOUND>";
            viewModel.TestFileLocation = config["TestFileLocation"];

            if (System.IO.File.Exists(viewModel.TestFileLocation))
            {
                viewModel.TestFile = System.IO.File.ReadAllText(viewModel.TestFileLocation);
            }

            viewModel.WebApiGetUri = config["TestGetUri"];
            var (success, message) = await GetTestUri(viewModel.WebApiGetUri);
            viewModel.WebApiGetResult = message;
            viewModel.WebApiGetSuccess = success;

            return View(viewModel);
        }

        private async Task<(bool,string)> GetTestUri(string uri)
        {
            if (!string.IsNullOrEmpty(uri))
            {
                var client = httpClientFactory.CreateClient(uri);
                try
                {
                    var body = await client.GetStringAsync(uri);
                    return (true,body);
                }
                catch(Exception e)
                {
                    return (false,e.Message);
                }
            }
            return (false,"No Test Uri provided");
        }
    }
}

