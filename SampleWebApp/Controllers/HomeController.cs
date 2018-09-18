using Microsoft.AspNetCore.Mvc;
using System.Text.Encodings.Web;
using Microsoft.Extensions.Configuration;
using Microsoft.AspNetCore.Hosting;
using System.Net.Http;
using System.IO;
using System.Threading.Tasks;

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
            var fileInfo = hostingEnv.ContentRootFileProvider.GetFileInfo(config["TestFileLocation"]);

            if (fileInfo.Exists)
            {
                using (var s = fileInfo.CreateReadStream())
                using (var t = new StreamReader(s))
                {
                    var contents = await t.ReadToEndAsync();
                    viewModel.TestFile = contents;
                }
            }

            var uri = config["TestGetUri"];
            if (!string.IsNullOrEmpty(uri))
            {
                var client = httpClientFactory.CreateClient("TestGetUri");
                viewModel.WebApiGetResult = await client.GetStringAsync(uri);
            }
            return View(viewModel);
        }
    }
}

