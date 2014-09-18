using System;
using System.Collections.Generic;
using M3.Helpers;
using M3.Models;
using Newegg.Framework.Web;


namespace PhotoGallery.Website.API
{
    public partial class GetDetail : System.Web.UI.Page
    {
        protected override void OnPreRender(EventArgs e)
        {
            int id = 1;
            int.TryParse(this.Request.QueryString["id"], out id);

            int page = 1;
            int.TryParse(this.Request.QueryString["page"], out page);

            if (id <= 0)
            {
                id = 1;
            }

            if (page <= 0)
            {
                page = 1;
            }


            string callBack = this.Request.QueryString["callBack"];

            if (string.IsNullOrEmpty(callBack))
            {
                return;
            }

            string lstString = JSON2.Serialize(GalleryHelper.GetPagedCategory(id, page, false));

            this.Response.Write(callBack + "(" + lstString + ")");
            this.Response.ContentType = "application/json";

            base.OnPreRender(e);
        }


        
    }
}