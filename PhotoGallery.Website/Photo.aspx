﻿<%@ Page Title="" Language="C#" MasterPageFile="~/Master/share.Master" AutoEventWireup="true" CodeBehind="Photo.aspx.cs" Inherits="PhotoGallery.Website.Photo" %>

<asp:Content ID="Content3" ContentPlaceHolderID="contentHeader" runat="server">
      <link href="~/Resources/css/album/vertical.css" rel="stylesheet" />
</asp:Content>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentArticle" runat="server">
   

</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="contentFooter" runat="server">
     <script src="~/Resources/js/album/jquery-migrate-1.2.1.min.js"></script>
    <script src="~/Resources/js/album/jquery.timers-1.1.2.js"></script>
    <script src="~/Resources/js/album/jquery.galleryview-1.0.js"></script>
    <script src="~/Resources/js/album/album.js"></script>
</asp:Content>