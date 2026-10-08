let
    Origen = Excel.Workbook(File.Contents("C:\Users\Vymax\OneDrive\Escritorio\Data Science coder\Módulo 6\Ventas_export_legacy.xlsx"), null, true),
    VENTAS_EXPORT_Sheet = Origen{[Item="VENTAS_EXPORT",Kind="Sheet"]}[Data],
    #"Encabezados promovidos" = Table.PromoteHeaders(VENTAS_EXPORT_Sheet, [PromoteAllScalars=true]),
    #"Tipo cambiado" = Table.TransformColumnTypes(#"Encabezados promovidos",{{"COD_OP", type text}, {"COD_CLI", type text}, {"NOM_CLI", type text}, {"MAIL_CLI", type text}, {"TEL_CLI", type text}, {"CIU_CLI", type text}, {"PROV_CLI", type text}, {"SEG_CLI", type text}, {"FLG_ACT", type text}, {"F_ALTA_CLI", type date}, {"F_VTA", type datetime}, {"COD_PROD", Int64.Type}, {"DESC_PROD", type text}, {"RUBRO_PROD", type text}, {"CANT", Int64.Type}, {"PU_VTA", type number}, {"DTO_PCT", type number}, {"TOT_VTA", type number}, {"COD_MON", type text}, {"CANAL_VTA", type text}}),
    #"Columnas con nombre cambiado" = Table.RenameColumns(#"Tipo cambiado",{{"COD_OP", "id_venta"}, {"COD_CLI", "id_cliente"}, {"NOM_CLI", "nombre_cliente"}, {"MAIL_CLI", "mail_cliente"}, {"TEL_CLI", "tel_cliente"}, {"CIU_CLI", "ciudad_cliente"}, {"PROV_CLI", "provincia_cliente"}, {"SEG_CLI", "segmento_cliente"}, {"FLG_ACT", "cliente_activo"}, {"F_ALTA_CLI", "fecha_alta"}, {"F_VTA", "fecha_venta"}, {"COD_PROD", "id_producto"}, {"DESC_PROD", "descripcion_producto"}, {"RUBRO_PROD", "categoria"}, {"CANT", "cantidad"}, {"PU_VTA", "precio_unitario"}, {"DTO_PCT", "descuento"}, {"TOT_VTA", "total_venta"}, {"COD_MON", "moneda"}, {"CANAL_VTA", "canal_venta"}}),
    #"Filas filtradas" = Table.SelectRows(#"Columnas con nombre cambiado", each true),
    #"Tipo cambiado1" = Table.TransformColumnTypes(#"Filas filtradas",{{"id_producto", type text}}),
    #"Filas filtradas1" = Table.SelectRows(#"Tipo cambiado1", each true),
    #"Filas en blanco eliminadas" = Table.SelectRows(#"Filas filtradas1", each not List.IsEmpty(List.RemoveMatchingItems(Record.FieldValues(_), {"", null}))),
    #"Filas filtradas2" = Table.SelectRows(#"Filas en blanco eliminadas", each true),
    #"Valor reemplazado" = Table.ReplaceValue(#"Filas filtradas2",null,"N/D",Replacer.ReplaceValue,{"mail_cliente"}),
    #"Valor reemplazado1" = Table.ReplaceValue(#"Valor reemplazado",null,"N/D",Replacer.ReplaceValue,{"tel_cliente"}),
    #"Filas filtradas3" = Table.SelectRows(#"Valor reemplazado1", each true),
    #"Valor reemplazado2" = Table.ReplaceValue(#"Filas filtradas3",null,0,Replacer.ReplaceValue,{"descuento"}),
    #"Tipo cambiado2" = Table.TransformColumnTypes(#"Valor reemplazado2",{{"descuento", Percentage.Type}}),
    #"Valor reemplazado3" = Table.ReplaceValue(#"Tipo cambiado2",null,each [cantidad] * [precio_unitario] * (1 - [descuento]),Replacer.ReplaceValue,{"total_venta"}),
    #"Tipo cambiado3" = Table.TransformColumnTypes(#"Valor reemplazado3",{{"total_venta", type number}})
in
    #"Tipo cambiado3"
