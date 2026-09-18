INSERT INTO mart.category(
        category_id,
        category_description,
        category_essential
) SELECT
        category_id,
        category_description,
        category_essential
FROM
        inter.clean_category;
