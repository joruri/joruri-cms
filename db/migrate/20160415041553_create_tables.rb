class CreateTables < ActiveRecord::Migration
  def change
    create_table "article_areas", force: :cascade do |t|
      t.integer  "unid",       limit: 4
      t.integer  "parent_id",  limit: 4,     null: false
      t.integer  "concept_id", limit: 4
      t.integer  "content_id", limit: 4
      t.string   "state",      limit: 15
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "level_no",   limit: 4,     null: false
      t.integer  "sort_no",    limit: 4
      t.integer  "layout_id",  limit: 4
      t.string   "name",       limit: 255
      t.text     "title",      limit: 65535
      t.text     "zip_code",   limit: 65535
      t.text     "address",    limit: 65535
      t.text     "tel",        limit: 65535
      t.text     "site_uri",   limit: 65535
    end

    create_table "article_attributes", force: :cascade do |t|
      t.integer  "unid",       limit: 4
      t.integer  "concept_id", limit: 4
      t.integer  "content_id", limit: 4
      t.string   "state",      limit: 15
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "sort_no",    limit: 4
      t.integer  "layout_id",  limit: 4
      t.string   "name",       limit: 255
      t.text     "title",      limit: 65535
    end

    create_table "article_categories", force: :cascade do |t|
      t.integer  "unid",       limit: 4
      t.integer  "parent_id",  limit: 4,     null: false
      t.integer  "concept_id", limit: 4
      t.integer  "content_id", limit: 4
      t.string   "state",      limit: 15
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "level_no",   limit: 4,     null: false
      t.integer  "sort_no",    limit: 4
      t.integer  "layout_id",  limit: 4
      t.string   "name",       limit: 255
      t.text     "title",      limit: 65535
    end

    create_table "article_docs", force: :cascade do |t|
      t.integer  "unid",             limit: 4
      t.integer  "content_id",       limit: 4
      t.string   "state",            limit: 15
      t.string   "agent_state",      limit: 15
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "recognized_at"
      t.datetime "published_at"
      t.integer  "language_id",      limit: 4
      t.string   "category_ids",     limit: 255
      t.string   "attribute_ids",    limit: 255
      t.string   "area_ids",         limit: 255
      t.string   "rel_doc_ids",      limit: 255
      t.text     "notice_state",     limit: 65535
      t.text     "recent_state",     limit: 65535
      t.text     "list_state",       limit: 65535
      t.text     "event_state",      limit: 65535
      t.date     "event_date"
      t.date     "event_close_date"
      t.string   "sns_link_state",   limit: 15
      t.string   "name",             limit: 255
      t.text     "title",            limit: 65535
      t.text     "head",             limit: 4294967295
      t.text     "body",             limit: 4294967295
      t.text     "mobile_title",     limit: 65535
      t.text     "mobile_body",      limit: 4294967295
    end

    add_index "article_docs", ["content_id", "published_at", "event_date"], name: "content_id", using: :btree

    create_table "article_tags", force: :cascade do |t|
      t.integer  "unid",       limit: 4
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name",       limit: 255
      t.text     "word",       limit: 65535
    end

    create_table "bbs_items", force: :cascade do |t|
      t.integer  "parent_id",  limit: 4
      t.integer  "thread_id",  limit: 4
      t.integer  "content_id", limit: 4
      t.string   "state",      limit: 15
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name",       limit: 255
      t.string   "email",      limit: 255
      t.string   "uri",        limit: 255
      t.text     "title",      limit: 65535
      t.text     "body",       limit: 4294967295
      t.string   "password",   limit: 15
      t.string   "ipaddr",     limit: 255
      t.string   "user_agent", limit: 255
    end

    create_table "calendar_events", force: :cascade do |t|
      t.integer  "unid",             limit: 4
      t.integer  "content_id",       limit: 4
      t.string   "state",            limit: 15
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "published_at"
      t.date     "event_date"
      t.date     "event_close_date"
      t.string   "event_uri",        limit: 255
      t.text     "title",            limit: 65535
      t.text     "body",             limit: 4294967295
    end

    add_index "calendar_events", ["content_id", "published_at", "event_date"], name: "content_id", using: :btree

    create_table "cms_concepts", force: :cascade do |t|
      t.integer  "unid",       limit: 4
      t.integer  "parent_id",  limit: 4
      t.integer  "site_id",    limit: 4
      t.string   "state",      limit: 15
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "level_no",   limit: 4,   null: false
      t.integer  "sort_no",    limit: 4
      t.string   "name",       limit: 255
    end

    add_index "cms_concepts", ["parent_id", "state", "sort_no"], name: "parent_id", using: :btree

    create_table "cms_content_settings", force: :cascade do |t|
      t.integer  "content_id", limit: 4,     null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name",       limit: 255
      t.text     "value",      limit: 65535
      t.integer  "sort_no",    limit: 4
    end

    add_index "cms_content_settings", ["content_id"], name: "content_id", using: :btree

    create_table "cms_contents", force: :cascade do |t|
      t.integer  "unid",           limit: 4
      t.integer  "site_id",        limit: 4,          null: false
      t.integer  "concept_id",     limit: 4
      t.string   "state",          limit: 15
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "model",          limit: 255
      t.string   "name",           limit: 255
      t.text     "xml_properties", limit: 4294967295
    end

    create_table "cms_data_file_nodes", force: :cascade do |t|
      t.integer  "unid",       limit: 4
      t.integer  "site_id",    limit: 4
      t.integer  "concept_id", limit: 4
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name",       limit: 255
      t.text     "title",      limit: 65535
    end

    add_index "cms_data_file_nodes", ["concept_id", "name"], name: "concept_id", using: :btree

    create_table "cms_data_files", force: :cascade do |t|
      t.integer  "unid",         limit: 4
      t.integer  "site_id",      limit: 4
      t.integer  "concept_id",   limit: 4
      t.integer  "node_id",      limit: 4
      t.string   "state",        limit: 15
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "published_at"
      t.string   "name",         limit: 255
      t.text     "title",        limit: 65535
      t.text     "mime_type",    limit: 65535
      t.integer  "size",         limit: 4
      t.integer  "image_is",     limit: 4
      t.integer  "image_width",  limit: 4
      t.integer  "image_height", limit: 4
      t.integer  "thumb_width",  limit: 4
      t.integer  "thumb_height", limit: 4
      t.integer  "thumb_size",   limit: 4
    end

    add_index "cms_data_files", ["concept_id", "node_id", "name"], name: "concept_id", using: :btree

    create_table "cms_data_texts", force: :cascade do |t|
      t.integer  "unid",         limit: 4
      t.integer  "site_id",      limit: 4
      t.integer  "concept_id",   limit: 4
      t.string   "state",        limit: 15
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "published_at"
      t.string   "name",         limit: 255
      t.text     "title",        limit: 65535
      t.text     "body",         limit: 4294967295
    end

    create_table "cms_embedded_files", force: :cascade do |t|
      t.integer  "unid",         limit: 4
      t.integer  "site_id",      limit: 4
      t.string   "state",        limit: 15
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "published_at"
      t.datetime "deleted_at"
      t.string   "name",         limit: 255
      t.text     "title",        limit: 65535
      t.text     "mime_type",    limit: 65535
      t.integer  "size",         limit: 4
      t.integer  "image_is",     limit: 4
      t.integer  "image_width",  limit: 4
      t.integer  "image_height", limit: 4
      t.integer  "thumb_width",  limit: 4
      t.integer  "thumb_height", limit: 4
      t.integer  "thumb_size",   limit: 4
    end

    create_table "cms_feed_entries", force: :cascade do |t|
      t.integer  "feed_id",        limit: 4
      t.integer  "content_id",     limit: 4
      t.text     "state",          limit: 65535
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "entry_id",       limit: 255
      t.datetime "entry_updated"
      t.date     "event_date"
      t.text     "title",          limit: 65535
      t.text     "summary",        limit: 4294967295
      t.text     "link_alternate", limit: 65535
      t.text     "link_enclosure", limit: 65535
      t.text     "categories",     limit: 65535
      t.text     "categories_xml", limit: 65535
      t.text     "author_name",    limit: 65535
      t.string   "author_email",   limit: 255
      t.text     "author_uri",     limit: 65535
    end

    add_index "cms_feed_entries", ["feed_id", "content_id", "entry_updated"], name: "feed_id", using: :btree

    create_table "cms_feeds", force: :cascade do |t|
      t.integer  "unid",                 limit: 4
      t.integer  "content_id",           limit: 4
      t.text     "state",                limit: 65535
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name",                 limit: 255,   null: false
      t.text     "uri",                  limit: 65535
      t.text     "title",                limit: 65535
      t.string   "feed_id",              limit: 255
      t.string   "feed_type",            limit: 255
      t.datetime "feed_updated"
      t.text     "feed_title",           limit: 65535
      t.text     "link_alternate",       limit: 65535
      t.integer  "entry_count",          limit: 4
      t.text     "fixed_categories_xml", limit: 65535
    end

    create_table "cms_inquiries", force: :cascade do |t|
      t.string   "state",      limit: 15
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "user_id",    limit: 4
      t.integer  "group_id",   limit: 4
      t.text     "charge",     limit: 65535
      t.text     "tel",        limit: 65535
      t.text     "fax",        limit: 65535
      t.text     "email",      limit: 65535
    end

    create_table "cms_kana_dictionaries", force: :cascade do |t|
      t.integer  "unid",       limit: 4
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name",       limit: 255
      t.text     "body",       limit: 4294967295
      t.text     "mecab_csv",  limit: 4294967295
    end

    create_table "cms_layouts", force: :cascade do |t|
      t.integer  "unid",                   limit: 4
      t.integer  "concept_id",             limit: 4
      t.integer  "template_id",            limit: 4
      t.integer  "site_id",                limit: 4,          null: false
      t.string   "state",                  limit: 15
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "recognized_at"
      t.datetime "published_at"
      t.string   "name",                   limit: 255
      t.text     "title",                  limit: 65535
      t.text     "head",                   limit: 4294967295
      t.text     "body",                   limit: 4294967295
      t.text     "stylesheet",             limit: 4294967295
      t.text     "mobile_head",            limit: 65535
      t.text     "mobile_body",            limit: 4294967295
      t.text     "mobile_stylesheet",      limit: 4294967295
      t.text     "smart_phone_head",       limit: 65535
      t.text     "smart_phone_body",       limit: 4294967295
      t.text     "smart_phone_stylesheet", limit: 4294967295
    end

    create_table "cms_link_checks", force: :cascade do |t|
      t.string   "state",        limit: 15
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "link_uri",     limit: 255
      t.text     "source_uri",   limit: 4294967295
      t.integer  "source_count", limit: 4
    end

    create_table "cms_map_markers", force: :cascade do |t|
      t.integer  "map_id",     limit: 4
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "sort_no",    limit: 4
      t.string   "name",       limit: 255
      t.string   "lat",        limit: 255
      t.string   "lng",        limit: 255
    end

    add_index "cms_map_markers", ["map_id"], name: "map_id", using: :btree

    create_table "cms_maps", force: :cascade do |t|
      t.integer  "unid",        limit: 4
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name",        limit: 255
      t.text     "title",       limit: 65535
      t.text     "map_lat",     limit: 65535
      t.text     "map_lng",     limit: 65535
      t.text     "map_zoom",    limit: 65535
      t.text     "point1_name", limit: 65535
      t.text     "point1_lat",  limit: 65535
      t.text     "point1_lng",  limit: 65535
      t.text     "point2_name", limit: 65535
      t.text     "point2_lat",  limit: 65535
      t.text     "point2_lng",  limit: 65535
      t.text     "point3_name", limit: 65535
      t.text     "point3_lat",  limit: 65535
      t.text     "point3_lng",  limit: 65535
      t.text     "point4_name", limit: 65535
      t.text     "point4_lat",  limit: 65535
      t.text     "point4_lng",  limit: 65535
      t.text     "point5_name", limit: 65535
      t.text     "point5_lat",  limit: 65535
      t.text     "point5_lng",  limit: 65535
    end

    create_table "cms_node_settings", force: :cascade do |t|
      t.integer  "node_id",    limit: 4,     null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name",       limit: 255
      t.text     "value",      limit: 65535
      t.integer  "sort_no",    limit: 4
    end

    add_index "cms_node_settings", ["node_id"], name: "node_id", using: :btree

    create_table "cms_nodes", force: :cascade do |t|
      t.integer  "unid",          limit: 4
      t.integer  "concept_id",    limit: 4
      t.integer  "site_id",       limit: 4
      t.string   "state",         limit: 15
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "recognized_at"
      t.datetime "published_at"
      t.integer  "parent_id",     limit: 4
      t.integer  "route_id",      limit: 4
      t.integer  "content_id",    limit: 4
      t.string   "model",         limit: 255
      t.integer  "directory",     limit: 4
      t.integer  "layout_id",     limit: 4
      t.string   "name",          limit: 255
      t.text     "title",         limit: 65535
      t.text     "body",          limit: 4294967295
      t.text     "mobile_title",  limit: 65535
      t.text     "mobile_body",   limit: 4294967295
    end

    add_index "cms_nodes", ["parent_id", "name"], name: "parent_id", using: :btree

    create_table "cms_piece_link_items", force: :cascade do |t|
      t.integer  "piece_id",   limit: 4,     null: false
      t.string   "state",      limit: 15
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name",       limit: 255
      t.text     "body",       limit: 65535
      t.string   "uri",        limit: 255
      t.integer  "sort_no",    limit: 4
      t.string   "target",     limit: 255
    end

    add_index "cms_piece_link_items", ["piece_id"], name: "piece_id", using: :btree

    create_table "cms_piece_settings", force: :cascade do |t|
      t.integer  "piece_id",   limit: 4,     null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name",       limit: 255
      t.text     "value",      limit: 65535
      t.integer  "sort_no",    limit: 4
    end

    add_index "cms_piece_settings", ["piece_id"], name: "piece_id", using: :btree

    create_table "cms_pieces", force: :cascade do |t|
      t.integer  "unid",           limit: 4
      t.integer  "concept_id",     limit: 4
      t.integer  "site_id",        limit: 4,          null: false
      t.string   "state",          limit: 15
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "recognized_at"
      t.datetime "published_at"
      t.integer  "content_id",     limit: 4
      t.string   "model",          limit: 255
      t.string   "name",           limit: 255
      t.text     "title",          limit: 65535
      t.string   "view_title",     limit: 255
      t.text     "head",           limit: 4294967295
      t.text     "body",           limit: 4294967295
      t.text     "xml_properties", limit: 4294967295
    end

    add_index "cms_pieces", ["concept_id", "name", "state"], name: "concept_id", using: :btree

    create_table "cms_site_settings", force: :cascade do |t|
      t.integer  "site_id",    limit: 4
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name",       limit: 32
      t.text     "value",      limit: 65535
      t.integer  "sort_no",    limit: 4
    end

    add_index "cms_site_settings", ["site_id", "name"], name: "concept_id", using: :btree

    create_table "cms_sites", force: :cascade do |t|
      t.integer  "unid",            limit: 4
      t.string   "state",           limit: 15
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name",            limit: 255
      t.string   "full_uri",        limit: 255
      t.string   "alias_full_uri",  limit: 255
      t.string   "mobile_full_uri", limit: 255
      t.string   "admin_full_uri",  limit: 255
      t.integer  "node_id",         limit: 4
      t.text     "related_site",    limit: 65535
    end

    create_table "cms_stylesheets", force: :cascade do |t|
      t.integer  "concept_id", limit: 4
      t.integer  "site_id",    limit: 4
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "path",       limit: 255
    end

    create_table "cms_talk_tasks", force: :cascade do |t|
      t.integer  "unid",         limit: 4
      t.string   "dependent",    limit: 64
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "published_at"
      t.text     "path",         limit: 65535
      t.string   "content_hash", limit: 255
    end

    add_index "cms_talk_tasks", ["unid", "dependent"], name: "unid", using: :btree

    create_table "enquete_answer_columns", force: :cascade do |t|
      t.integer "answer_id", limit: 4
      t.integer "form_id",   limit: 4
      t.integer "column_id", limit: 4
      t.text    "value",     limit: 4294967295
    end

    add_index "enquete_answer_columns", ["answer_id", "form_id", "column_id"], name: "answer_id", using: :btree

    create_table "enquete_answers", force: :cascade do |t|
      t.integer  "content_id", limit: 4
      t.integer  "form_id",    limit: 4
      t.string   "state",      limit: 15
      t.datetime "created_at"
      t.string   "ipaddr",     limit: 255
      t.text     "user_agent", limit: 65535
    end

    add_index "enquete_answers", ["content_id", "form_id"], name: "content_id", using: :btree

    create_table "enquete_form_columns", force: :cascade do |t|
      t.integer  "unid",         limit: 4
      t.integer  "form_id",      limit: 4
      t.string   "state",        limit: 15
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "sort_no",      limit: 4
      t.text     "name",         limit: 65535
      t.text     "body",         limit: 65535
      t.string   "column_type",  limit: 255
      t.string   "column_style", limit: 255
      t.integer  "required",     limit: 4
      t.text     "options",      limit: 4294967295
    end

    add_index "enquete_form_columns", ["form_id", "sort_no"], name: "form_id", using: :btree

    create_table "enquete_forms", force: :cascade do |t|
      t.integer  "unid",       limit: 4
      t.integer  "content_id", limit: 4
      t.string   "state",      limit: 15
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "sort_no",    limit: 4
      t.text     "name",       limit: 65535
      t.text     "body",       limit: 4294967295
      t.text     "summary",    limit: 65535
      t.text     "sent_body",  limit: 4294967295
    end

    add_index "enquete_forms", ["content_id", "sort_no"], name: "content_id", using: :btree

    create_table "entity_conversion_logs", force: :cascade do |t|
      t.integer  "content_id", limit: 4
      t.string   "env",        limit: 15
      t.string   "state",      limit: 15
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "body",       limit: 4294967295
    end

    create_table "entity_conversion_units", force: :cascade do |t|
      t.integer  "unid",          limit: 4
      t.integer  "content_id",    limit: 4
      t.string   "state",         limit: 15
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "old_id",        limit: 4
      t.integer  "old_parent_id", limit: 4
      t.integer  "move_id",       limit: 4
      t.integer  "new_move_id",   limit: 4
      t.integer  "parent_id",     limit: 4
      t.integer  "new_parent_id", limit: 4
      t.string   "code",          limit: 255
      t.string   "name",          limit: 255
      t.string   "name_en",       limit: 255
      t.string   "tel",           limit: 255
      t.string   "outline_uri",   limit: 255
      t.string   "email",         limit: 255
      t.string   "web_state",     limit: 15
      t.integer  "layout_id",     limit: 4
      t.integer  "ldap",          limit: 4
      t.integer  "sort_no",       limit: 4
    end

    create_table "faq_categories", force: :cascade do |t|
      t.integer  "unid",       limit: 4
      t.integer  "parent_id",  limit: 4,     null: false
      t.integer  "concept_id", limit: 4
      t.integer  "content_id", limit: 4
      t.string   "state",      limit: 15
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "level_no",   limit: 4,     null: false
      t.integer  "sort_no",    limit: 4
      t.integer  "layout_id",  limit: 4
      t.string   "name",       limit: 255
      t.text     "title",      limit: 65535
    end

    create_table "faq_docs", force: :cascade do |t|
      t.integer  "unid",          limit: 4
      t.integer  "content_id",    limit: 4
      t.string   "state",         limit: 15
      t.string   "agent_state",   limit: 15
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "recognized_at"
      t.datetime "published_at"
      t.integer  "language_id",   limit: 4
      t.string   "category_ids",  limit: 255
      t.string   "rel_doc_ids",   limit: 255
      t.text     "notice_state",  limit: 65535
      t.text     "recent_state",  limit: 65535
      t.string   "name",          limit: 255
      t.text     "question",      limit: 65535
      t.text     "title",         limit: 65535
      t.text     "head",          limit: 4294967295
      t.text     "body",          limit: 4294967295
      t.text     "mobile_title",  limit: 65535
      t.text     "mobile_body",   limit: 4294967295
    end

    add_index "faq_docs", ["content_id", "published_at"], name: "content_id", using: :btree

    create_table "faq_tags", force: :cascade do |t|
      t.integer  "unid",       limit: 4
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name",       limit: 255
      t.text     "word",       limit: 65535
    end

    create_table "newsletter_docs", force: :cascade do |t|
      t.integer  "unid",           limit: 4
      t.integer  "content_id",     limit: 4
      t.string   "state",          limit: 15
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "delivery_state", limit: 15
      t.datetime "started_at"
      t.datetime "delivered_at"
      t.string   "name",           limit: 255
      t.text     "title",          limit: 65535
      t.text     "body",           limit: 4294967295
      t.text     "mobile_title",   limit: 65535
      t.text     "mobile_body",    limit: 4294967295
      t.integer  "total_count",    limit: 4
      t.integer  "success_count",  limit: 4
      t.integer  "error_count",    limit: 4
    end

    add_index "newsletter_docs", ["content_id", "updated_at"], name: "content_id", using: :btree

    create_table "newsletter_logs", force: :cascade do |t|
      t.integer  "content_id",  limit: 4
      t.integer  "doc_id",      limit: 4
      t.string   "state",       limit: 15
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "member_id",   limit: 4
      t.text     "email",       limit: 65535
      t.string   "letter_type", limit: 15
      t.text     "message",     limit: 65535
    end

    create_table "newsletter_members", force: :cascade do |t|
      t.integer  "unid",             limit: 4
      t.integer  "content_id",       limit: 4
      t.string   "state",            limit: 15
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "letter_type",      limit: 15
      t.text     "email",            limit: 65535
      t.integer  "delivered_doc_id", limit: 4
      t.datetime "delivered_at"
    end

    add_index "newsletter_members", ["content_id", "letter_type", "created_at"], name: "content_id", using: :btree

    create_table "newsletter_requests", force: :cascade do |t|
      t.integer  "content_id",   limit: 4
      t.string   "state",        limit: 15
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "request_type", limit: 15
      t.text     "email",        limit: 65535
      t.string   "letter_type",  limit: 15
      t.string   "ipaddr",       limit: 255
    end

    add_index "newsletter_requests", ["content_id", "request_type"], name: "content_id", using: :btree

    create_table "newsletter_testers", force: :cascade do |t|
      t.integer  "unid",        limit: 4
      t.integer  "content_id",  limit: 4
      t.string   "state",       limit: 15
      t.string   "agent_state", limit: 15
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "name",        limit: 65535
      t.text     "email",       limit: 65535
    end

    create_table "portal_categories", force: :cascade do |t|
      t.integer  "unid",             limit: 4
      t.integer  "parent_id",        limit: 4,          null: false
      t.integer  "content_id",       limit: 4
      t.string   "state",            limit: 15
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "level_no",         limit: 4,          null: false
      t.integer  "sort_no",          limit: 4
      t.integer  "layout_id",        limit: 4
      t.string   "name",             limit: 255
      t.text     "title",            limit: 65535
      t.text     "entry_categories", limit: 4294967295
    end

    add_index "portal_categories", ["parent_id", "content_id", "state"], name: "parent_id", using: :btree

    create_table "sessions", force: :cascade do |t|
      t.string   "session_id", limit: 255,   null: false
      t.text     "data",       limit: 65535
      t.datetime "created_at",               null: false
      t.datetime "updated_at",               null: false
    end

    add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
    add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

    create_table "simple_captcha_data", force: :cascade do |t|
      t.string   "key",        limit: 40
      t.string   "value",      limit: 6
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "simple_captcha_data", ["key"], name: "idx_key", using: :btree

    create_table "storage_files", force: :cascade do |t|
      t.datetime "created_at",                    null: false
      t.datetime "updated_at",                    null: false
      t.string   "path",       limit: 255,        null: false
      t.string   "dirname",    limit: 255,        null: false
      t.string   "basename",   limit: 255,        null: false
      t.boolean  "directory",                     null: false
      t.integer  "size",       limit: 8
      t.binary   "data",       limit: 4294967295
      t.string   "path_hash",  limit: 32
      t.string   "dir_hash",   limit: 32
    end

    add_index "storage_files", ["path"], name: "path", unique: true, using: :btree

    create_table "sys_creators", force: :cascade do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "user_id",    limit: 4
      t.integer  "group_id",   limit: 4
    end

    create_table "sys_editable_groups", force: :cascade do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "group_ids",  limit: 65535
    end

    create_table "sys_files", force: :cascade do |t|
      t.integer  "unid",         limit: 4
      t.string   "tmp_id",       limit: 255
      t.integer  "parent_unid",  limit: 4
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name",         limit: 255
      t.text     "title",        limit: 65535
      t.text     "mime_type",    limit: 65535
      t.integer  "size",         limit: 4
      t.integer  "image_is",     limit: 4
      t.integer  "image_width",  limit: 4
      t.integer  "image_height", limit: 4
      t.integer  "thumb_width",  limit: 4
      t.integer  "thumb_height", limit: 4
      t.integer  "thumb_size",   limit: 4
    end

    add_index "sys_files", ["parent_unid", "name"], name: "parent_unid", using: :btree

    create_table "sys_groups", force: :cascade do |t|
      t.integer  "unid",         limit: 4
      t.string   "state",        limit: 15
      t.string   "web_state",    limit: 15
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "parent_id",    limit: 4,   null: false
      t.integer  "level_no",     limit: 4
      t.string   "code",         limit: 255, null: false
      t.integer  "sort_no",      limit: 4
      t.integer  "layout_id",    limit: 4
      t.integer  "ldap",         limit: 4,   null: false
      t.string   "ldap_version", limit: 255
      t.string   "name",         limit: 255
      t.string   "name_en",      limit: 255
      t.string   "tel",          limit: 255
      t.string   "outline_uri",  limit: 255
      t.string   "email",        limit: 255
    end

    create_table "sys_languages", force: :cascade do |t|
      t.string   "state",      limit: 15
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "sort_no",    limit: 4
      t.string   "name",       limit: 255
      t.text     "title",      limit: 65535
    end

    create_table "sys_ldap_synchros", force: :cascade do |t|
      t.integer  "parent_id",  limit: 4
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "version",    limit: 10
      t.string   "entry_type", limit: 15
      t.string   "code",       limit: 255
      t.integer  "sort_no",    limit: 4
      t.string   "name",       limit: 255
      t.string   "name_en",    limit: 255
      t.string   "email",      limit: 255
    end

    add_index "sys_ldap_synchros", ["version", "parent_id", "entry_type"], name: "version", using: :btree

    create_table "sys_maintenances", force: :cascade do |t|
      t.integer  "unid",         limit: 4
      t.string   "state",        limit: 15
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "published_at"
      t.text     "title",        limit: 65535
      t.text     "body",         limit: 65535
    end

    create_table "sys_messages", force: :cascade do |t|
      t.integer  "unid",         limit: 4
      t.string   "state",        limit: 15
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "published_at"
      t.text     "title",        limit: 65535
      t.text     "body",         limit: 65535
    end

    create_table "sys_object_privileges", force: :cascade do |t|
      t.integer  "role_id",    limit: 4
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "item_unid",  limit: 4
      t.string   "action",     limit: 15
    end

    add_index "sys_object_privileges", ["item_unid", "action"], name: "item_unid", using: :btree

    create_table "sys_operation_logs", force: :cascade do |t|
      t.datetime "created_at"
      t.integer  "user_id",    limit: 4
      t.string   "user_name",  limit: 255
      t.string   "ipaddr",     limit: 255
      t.string   "uri",        limit: 255
      t.string   "action",     limit: 255
      t.string   "item_model", limit: 255
      t.integer  "item_id",    limit: 4
      t.integer  "item_unid",  limit: 4
      t.string   "item_name",  limit: 255
    end

    create_table "sys_processes", force: :cascade do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "started_at"
      t.datetime "closed_at"
      t.integer  "user_id",    limit: 4
      t.string   "state",      limit: 255
      t.string   "name",       limit: 255
      t.string   "interrupt",  limit: 255
      t.integer  "total",      limit: 4
      t.integer  "current",    limit: 4
      t.integer  "success",    limit: 4
      t.integer  "error",      limit: 4
      t.text     "message",    limit: 4294967295
    end

    create_table "sys_publishers", force: :cascade do |t|
      t.integer  "unid",           limit: 4
      t.integer  "rel_unid",       limit: 4
      t.integer  "site_id",        limit: 4
      t.string   "dependent",      limit: 64
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "path",           limit: 255
      t.string   "uri",            limit: 255
      t.string   "content_hash",   limit: 255
      t.text     "internal_links", limit: 4294967295
      t.text     "external_links", limit: 4294967295
    end

    add_index "sys_publishers", ["rel_unid"], name: "rel_unid", using: :btree
    add_index "sys_publishers", ["unid"], name: "unid", using: :btree

    create_table "sys_recognitions", force: :cascade do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "user_id",        limit: 4
      t.string   "recognizer_ids", limit: 255
      t.text     "info_xml",       limit: 65535
    end

    add_index "sys_recognitions", ["user_id"], name: "user_id", using: :btree

    create_table "sys_role_names", force: :cascade do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name",       limit: 255
      t.text     "title",      limit: 65535
    end

    create_table "sys_sequences", force: :cascade do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name",       limit: 255
      t.integer  "version",    limit: 4
      t.integer  "value",      limit: 4
    end

    add_index "sys_sequences", ["name", "version"], name: "name", using: :btree

    create_table "sys_settings", force: :cascade do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name",       limit: 255
      t.text     "value",      limit: 65535
      t.integer  "sort_no",    limit: 4
    end

    create_table "sys_tasks", force: :cascade do |t|
      t.integer  "unid",       limit: 4
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "process_at"
      t.string   "name",       limit: 255
    end

    create_table "sys_unid_relations", force: :cascade do |t|
      t.integer "unid",     limit: 4,   null: false
      t.integer "rel_unid", limit: 4,   null: false
      t.string  "rel_type", limit: 255, null: false
    end

    add_index "sys_unid_relations", ["rel_unid"], name: "rel_unid", using: :btree
    add_index "sys_unid_relations", ["unid"], name: "unid", using: :btree

    create_table "sys_unids", force: :cascade do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "model",      limit: 255, null: false
      t.integer  "item_id",    limit: 4
    end

    create_table "sys_users", force: :cascade do |t|
      t.string   "state",                     limit: 15
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "ldap",                      limit: 4,     null: false
      t.string   "ldap_version",              limit: 255
      t.integer  "auth_no",                   limit: 4,     null: false
      t.string   "name",                      limit: 255
      t.string   "name_en",                   limit: 255
      t.string   "account",                   limit: 255
      t.string   "password",                  limit: 255
      t.string   "email",                     limit: 255
      t.text     "remember_token",            limit: 65535
      t.datetime "remember_token_expires_at"
    end

    create_table "sys_users_groups", primary_key: "rid", force: :cascade do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "user_id",    limit: 4
      t.integer  "group_id",   limit: 4
    end

    add_index "sys_users_groups", ["user_id", "group_id"], name: "user_id", using: :btree

    create_table "sys_users_roles", primary_key: "rid", force: :cascade do |t|
      t.integer "group_id", limit: 4
      t.integer "user_id",  limit: 4
      t.integer "role_id",  limit: 4
    end

    add_index "sys_users_roles", ["user_id", "role_id"], name: "user_id", using: :btree

  end
end
