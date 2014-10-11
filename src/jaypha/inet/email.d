
module jaypha.inet.email;

public import jaypha.inet.imf.writing;
public import jaypha.inet.mime.writing;

import std.file;
import std.process;
import std.array;

import std.stdio;
import jaypha.types;
import jaypha.io.dirtyio;

struct Email
{
  struct Attachment
  {
    string name;
    string mimeType;
    ByteArray content;
    string fileName;
  }

  private MimeHeader[] headers;
  void addHeader(string name, string fieldBody) { headers ~= unstructuredHeader(name,fieldBody); }

  string subject;
  Mailbox from;
  Mailbox[] to, cc, bcc;

  string text, html;

  Attachment[] attachments;

  void copy(R) (R range) if (isOutputRange(R,ByteArray))
  {
    auto entity = build();
    entity.copy(range);
  }

  version(linux)
  {
    bool sendmail()
    {
      auto entity = build();

      auto pipes = pipeProcess(["sendmail","-t","-i"]);
      auto wout = WriteOut(pipes.stdin);
      entity.copy(wout);
      pipes.stdin.close();
      wait(pipes.pid);
      return true; // TODO get result from process.
    }
  }

  private MimeEntity build()
  {
    MimeEntity entity;

    if (!attachments.empty)
    {
      entity = getMultiPart("mixed");
      entity.content.bodParts ~= getMessagePart();
      foreach (a;attachments)
        entity.content.bodParts ~= getAttachmentPart(a);
    }
    else
      entity = getMessagePart();

    entity.headers ~= mimeVersion;

    entity.headers ~= unstructuredHeader("Subject",subject);
    entity.headers ~= addressHeader("From", [ from ] );
    if (!to.empty) entity.headers ~= addressHeader("To", to);
    if (!cc.empty) entity.headers ~= addressHeader("Cc", cc);
    if (!bcc.empty) entity.headers ~= addressHeader("Bcc", cc);
  
    entity.headers ~= headers;
    
    return entity;
  }

  private MimeEntity getMessagePart()
  {
    if (!html.empty)
    {
      if (!text.empty)
      {
        auto entity = getMultiPart("alternate");
        entity.content.bodParts ~= getHtmlPart();
        entity.content.bodParts ~= getTextPart();
        return entity;
      }
      else
        return getHtmlPart();
    }
    else
      return getTextPart();
  }

  private MimeEntity getTextPart()
  {
    MimeContentType ct;
    ct.type = "text/plain";
    ct.parameters["charset"] = "UTF-8";
    
    auto entity = MimeEntity(ct, true);
    entity.encoding = "8bit";

    entity.content.bod = cast(ByteArray) text;

    return entity;
  }

  private MimeEntity getMultiPart(string type)
  {
    MimeContentType ct;
    ct.type = "multipart/"~type;
    auto entity = MimeEntity(ct, true);
    return entity;
  }

  private MimeEntity getHtmlPart()
  {
    MimeContentType ct;
    ct.type = "text/html";
    ct.parameters["charset"] = "UTF-8";
    
    auto entity = MimeEntity(ct, true);
    entity.encoding = "8bit";

    entity.content.bod = cast(ByteArray) html;

    return entity;
  }

  private MimeEntity getAttachmentPart(ref Attachment a)
  {
    MimeContentType ct;
    ct.type = a.mimeType;
    MimeContentDisposition disp;
    if (ct.type[0..5] != "image")
      disp.type = "attachment";
    disp.parameters["filename"] = a.name;
    
    auto entity = MimeEntity(ct, true);
    entity.headers ~= disp.toHeader();
    entity.encoding = "base64";
    if (!a.content.empty)
      entity.content.bod = a.content;
    else
      entity.content.bod = cast(ByteArray) read(a.fileName);

    return entity;
  }
}
