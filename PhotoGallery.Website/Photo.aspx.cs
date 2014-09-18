using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PhotoGallery.Website
{
    public partial class Photo : System.Web.UI.Page
    {
        protected override void OnPreRender(EventArgs e)
        {
            CategoryID = this.Request.QueryString["categoryId"];
            PhotoID = this.Request.QueryString["photoId"];

            base.OnPreRender(e);
        }


        protected string CategoryID { get; set; }

        protected string PhotoID { get; set; }
    }
}