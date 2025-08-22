//myCustomTypeDatatable.js
import LightningDatatable from "lightning/datatable";
import customImageTemplate from "./customImage.html";
import customPicklistTemplate from "./customPicklist.html";
import customPicklisteditTemplate from "./customPicklistedit.html";

export default class MyCustomTypeDatatable extends LightningDatatable {
  static customTypes = {
 
       customImage: {
      template: customImageTemplate,
      standardCellLayout: true,
      typeAttributes: ["url"],
    },
    customPicklist: {
      template: customPicklistTemplate,
      editTemplate :customPicklisteditTemplate,
      standardCellLayout: true,
      typeAttributes: ["options","value","context"],
    },

  
  };
}