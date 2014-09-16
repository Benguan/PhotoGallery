using System;
using System.Collections.Generic;

using M3.Helpers;
using M3.Models;
using Newegg.Framework.Web;


namespace PhotoGallery.Website.API
{
    public partial class GetDetails : System.Web.UI.Page
    {
        protected override void OnPreRender(EventArgs e)
        {
            string ids = this.Request.QueryString["ids"];
            int page = Convert.ToInt32(this.Request.QueryString["page"]);
            string callBack = this.Request.QueryString["callBack"];

            if (string.IsNullOrEmpty(ids) || string.IsNullOrEmpty(callBack))
            {
                return;
            }

            string lstString = JSON2.Serialize(GetCategory(ids, page));

            this.Response.Write(callBack + "(" + lstString + ")");
            this.Response.ContentType = "application/json";

            base.OnPreRender(e);
        }


        protected List<Category> GetCategory(string ids, int page)
        {
            var categories = new List<Category>();

            var idList = StringHelper.GetIntList(ids);

            foreach (var id in idList)
            {
                categories.Add(GalleryHelper.GetPagedCategory(id, page, true));
            }
            return categories;
        }
    }
}